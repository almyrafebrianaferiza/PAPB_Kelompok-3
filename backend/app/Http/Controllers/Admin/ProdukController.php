<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DetailPesanan;
use App\Models\Keranjang;
use App\Models\Produk;
use App\Models\ProdukVarian;
use App\Services\ServisStok;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class ProdukController extends Controller
{
    public function __construct(
        protected ServisStok $servisStok
    ) {}

    /**
     * Menampilkan katalog produk dengan filter kategori, pencarian, dan stok kritis.
     */
    public function index(Request $request): View
    {
        $kategori = $request->query('kategori');
        $cari = trim((string) $request->query('cari'));
        $hanyaKritis = $request->query('stok') === 'kritis';

        $produk = Produk::withCount('varian')
            ->when($kategori, fn ($query) => $query->where('kategori', $kategori))
            ->when($cari !== '', function ($query) use ($cari): void {
                $query->where(function ($sub) use ($cari): void {
                    $sub->where('nama', 'like', "%{$cari}%")
                        ->orWhere('merek', 'like', "%{$cari}%");
                });
            })
            ->when($hanyaKritis, fn ($query) => $query->where('stok', '<', 3))
            ->orderByDesc('id')
            ->paginate(15)
            ->withQueryString();

        return view('admin.produk.index', [
            'judulHalaman' => 'Katalog Produk',
            'produk' => $produk,
            'daftarKategori' => config('zenvora.kategori'),
            'kategoriTerpilih' => $kategori,
            'cari' => $cari,
            'hanyaKritis' => $hanyaKritis,
        ]);
    }

    /**
     * Menampilkan formulir tambah produk.
     */
    public function create(): View
    {
        return view('admin.produk.form', [
            'judulHalaman' => 'Tambah Produk',
            'produk' => new Produk,
            'daftarKategori' => config('zenvora.kategori'),
            'mode' => 'create',
        ]);
    }

    /**
     * Menyimpan produk baru beserta varian dan unit serialnya.
     */
    public function store(Request $request): RedirectResponse
    {
        $data = $this->validasi($request);

        $produk = DB::transaction(function () use ($data): Produk {
            $daftarVarian = $this->normalisasiVarian($data['varian'] ?? []);
            $stokTarget = $daftarVarian === []
                ? (int) $data['stok']
                : array_sum(array_column($daftarVarian, 'stok'));

            $produk = Produk::create([
                'nama' => $data['nama'],
                'merek' => $data['merek'],
                'harga' => (int) $data['harga'],
                'kategori' => $data['kategori'],
                'stok' => 0,
                'tersedia' => (bool) ($data['tersedia'] ?? false),
                'deskripsi' => $data['deskripsi'] ?? null,
                'berat_gram' => (int) $data['berat_gram'],
                'garansi_bulan' => (int) $data['garansi_bulan'],
            ]);

            foreach ($daftarVarian as $varian) {
                $produk->varian()->create($varian);
            }

            $this->servisStok->buatUnit($produk, $stokTarget);

            return $produk;
        });

        return redirect()
            ->route('admin.produk.edit', $produk)
            ->with('status', "Produk {$produk->nama} berhasil ditambahkan.");
    }

    /**
     * Menampilkan formulir ubah produk dan variannya.
     */
    public function edit(Produk $produk): View
    {
        $produk->load('varian');

        return view('admin.produk.form', [
            'judulHalaman' => 'Ubah Produk',
            'produk' => $produk,
            'daftarKategori' => config('zenvora.kategori'),
            'mode' => 'edit',
        ]);
    }

    /**
     * Memperbarui produk, menyinkronkan varian, dan menyesuaikan unit fisik.
     */
    public function update(Request $request, Produk $produk): RedirectResponse
    {
        $data = $this->validasi($request);

        DB::transaction(function () use ($data, $produk): void {
            $daftarVarian = $this->normalisasiVarian($data['varian'] ?? []);
            $stokTarget = $daftarVarian === []
                ? (int) $data['stok']
                : array_sum(array_column($daftarVarian, 'stok'));

            $produk->update([
                'nama' => $data['nama'],
                'merek' => $data['merek'],
                'harga' => (int) $data['harga'],
                'kategori' => $data['kategori'],
                'tersedia' => (bool) ($data['tersedia'] ?? false),
                'deskripsi' => $data['deskripsi'] ?? null,
                'berat_gram' => (int) $data['berat_gram'],
                'garansi_bulan' => (int) $data['garansi_bulan'],
            ]);

            $this->sinkronkanVarian($produk, $daftarVarian);
            $this->servisStok->sesuaikanUnitKeTarget($produk, $stokTarget);
        });

        return redirect()
            ->route('admin.produk.edit', $produk)
            ->with('status', "Produk {$produk->nama} berhasil diperbarui.");
    }

    /**
     * Menghapus produk dengan proteksi pesanan aktif.
     */
    public function destroy(Produk $produk): RedirectResponse
    {
        $idPesananAktif = DetailPesanan::where('produk_id', $produk->id)
            ->whereHas('pesanan', function ($query): void {
                $query->whereNotIn('status', ['selesai', 'dibatalkan']);
            })
            ->exists();

        if ($idPesananAktif) {
            return back()->withErrors([
                'produk' => 'Produk tidak dapat dihapus karena masih dipakai pada pesanan berjalan.',
            ]);
        }

        DB::transaction(function () use ($produk): void {
            $produk->delete();
            Keranjang::where('produk_id', $produk->id)->delete();
        });

        return redirect()
            ->route('admin.produk.index')
            ->with('status', "Produk {$produk->nama} berhasil dihapus.");
    }

    /**
     * Aturan validasi formulir produk dan varian.
     *
     * @return array<string, mixed>
     */
    private function validasi(Request $request): array
    {
        return $request->validate([
            'nama' => ['required', 'string', 'max:150'],
            'merek' => ['required', 'string', 'max:60'],
            'harga' => ['required', 'integer', 'min:0'],
            'kategori' => ['required', 'string', Rule::in(config('zenvora.kategori'))],
            'stok' => ['required', 'integer', 'min:0'],
            'tersedia' => ['nullable', 'boolean'],
            'deskripsi' => ['nullable', 'string'],
            'berat_gram' => ['required', 'integer', 'min:1'],
            'garansi_bulan' => ['required', 'integer', 'min:0'],

            'varian' => ['nullable', 'array'],
            'varian.*.id' => ['nullable', 'integer'],
            'varian.*.nama_varian' => ['nullable', 'string', 'max:100'],
            'varian.*.harga' => ['nullable', 'integer', 'min:0'],
            'varian.*.stok' => ['nullable', 'integer', 'min:0'],
            'varian.*.berat_gram' => ['nullable', 'integer', 'min:0'],
            'varian.*.sku' => ['nullable', 'string', 'max:50'],
        ], [
            'nama.required' => 'Nama produk wajib diisi.',
            'merek.required' => 'Merek produk wajib diisi.',
            'harga.required' => 'Harga produk wajib diisi.',
            'kategori.in' => 'Kategori tidak dikenali.',
            'stok.required' => 'Stok produk wajib diisi.',
            'berat_gram.required' => 'Berat produk wajib diisi.',
            'garansi_bulan.required' => 'Masa garansi wajib diisi.',
            'varian.*.nama_varian.max' => 'Nama varian maksimal 100 karakter.',
            'varian.*.sku.max' => 'SKU maksimal 50 karakter.',
        ]);
    }

    /**
     * Menyaring baris varian kosong dan menormalkan nilainya.
     *
     * @param  array<int, array<string, mixed>>  $varian
     * @return array<int, array<string, mixed>>
     */
    private function normalisasiVarian(array $varian): array
    {
        $hasil = [];

        foreach ($varian as $baris) {
            $nama = trim((string) ($baris['nama_varian'] ?? ''));

            if ($nama === '') {
                continue;
            }

            $hasil[] = [
                'id' => isset($baris['id']) && $baris['id'] !== '' ? (int) $baris['id'] : null,
                'nama_varian' => $nama,
                'harga' => (int) ($baris['harga'] ?? 0),
                'stok' => (int) ($baris['stok'] ?? 0),
                'berat_gram' => (int) ($baris['berat_gram'] ?? 0),
                'sku' => trim((string) ($baris['sku'] ?? '')) ?: null,
            ];
        }

        return $hasil;
    }

    /**
     * Menyamakan data varian tersimpan dengan kiriman formulir.
     *
     * @param  array<int, array<string, mixed>>  $daftarVarian
     */
    private function sinkronkanVarian(Produk $produk, array $daftarVarian): void
    {
        $idDikirim = array_values(array_filter(array_column($daftarVarian, 'id')));

        $produk->varian()->whereNotIn('id', $idDikirim)->delete();

        foreach ($daftarVarian as $baris) {
            $atribut = [
                'nama_varian' => $baris['nama_varian'],
                'harga' => $baris['harga'],
                'stok' => $baris['stok'],
                'berat_gram' => $baris['berat_gram'],
                'sku' => $baris['sku'],
            ];

            if ($baris['id']) {
                ProdukVarian::where('produk_id', $produk->id)
                    ->whereKey($baris['id'])
                    ->update($atribut);
            } else {
                $produk->varian()->create($atribut);
            }
        }
    }
}
