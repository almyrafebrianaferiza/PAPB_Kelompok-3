<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SimpanProdukRequest;
use App\Models\DetailPesanan;
use App\Models\Keranjang;
use App\Models\Pesanan;
use App\Models\Produk;
use App\Services\ServisStok;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukController extends Controller
{
    public function __construct(
        protected ServisStok $servisStok
    ) {}

    /**
     * GET /api/produk (Paginasi Lazy Load, Filter, Cari)
     */
    public function index(Request $request): JsonResponse
    {
        $halaman = (int) $request->query('halaman', 1);
        $perHalaman = (int) $request->query('per_halaman', 10);

        if ($halaman < 1 || $perHalaman < 1 || $perHalaman > 50) {
            return Respons::gagal('Parameter halaman atau per_halaman tidak valid', 422, [
                'halaman' => ['Halaman minimal 1 dan per_halaman antara 1 hingga 50'],
            ]);
        }

        $query = Produk::query();

        if ($request->filled('kategori')) {
            $query->where('kategori', strtolower($request->query('kategori')));
        }

        if ($request->filled('cari')) {
            $cari = strtolower($request->query('cari'));
            $query->where(function ($q) use ($cari) {
                $q->whereRaw('LOWER(nama) LIKE ?', ["%{$cari}%"])
                    ->orWhereRaw('LOWER(merek) LIKE ?', ["%{$cari}%"]);
            });
        }

        // Urutan stabil ID naik
        $offset = ($halaman - 1) * $perHalaman;
        $produk = $query->with('varian')->orderBy('id', 'asc')
            ->skip($offset)
            ->take($perHalaman)
            ->get();

        return Respons::sukses($produk, 'Daftar produk berhasil diambil', 200);
    }

    /**
     * GET /api/produk/{id}
     */
    public function show(int $id): JsonResponse
    {
        $produk = Produk::with('varian')->find($id);

        if (! $produk) {
            return Respons::gagal('Produk tidak ditemukan', 404);
        }

        return Respons::sukses($produk, 'Rincian produk berhasil diambil', 200);
    }

    /**
     * POST /api/produk
     */
    public function store(SimpanProdukRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $produk = DB::transaction(function () use ($validated) {
            $prod = Produk::create([
                'nama' => $validated['nama'],
                'merek' => $validated['merek'],
                'harga' => $validated['harga'],
                'kategori' => $validated['kategori'],
                'stok' => 0,
                'tersedia' => $validated['tersedia'] ?? true,
                'deskripsi' => $validated['deskripsi'] ?? null,
                'berat_gram' => $validated['berat_gram'],
                'garansi_bulan' => $validated['garansi_bulan'],
            ]);

            $this->servisStok->buatUnit($prod, (int) $validated['stok']);

            return $prod->fresh();
        });

        return Respons::sukses($produk, 'Produk berhasil ditambahkan', 201);
    }

    /**
     * PUT /api/produk/{id}
     */
    public function update(SimpanProdukRequest $request, int $id): JsonResponse
    {
        $produk = Produk::find($id);

        if (! $produk) {
            return Respons::gagal('Produk tidak ditemukan', 404);
        }

        $validated = $request->validated();

        DB::transaction(function () use ($produk, $validated) {
            $produk->update([
                'nama' => $validated['nama'],
                'merek' => $validated['merek'],
                'harga' => $validated['harga'],
                'kategori' => $validated['kategori'],
                'tersedia' => $validated['tersedia'] ?? true,
                'deskripsi' => $validated['deskripsi'] ?? null,
                'berat_gram' => $validated['berat_gram'],
                'garansi_bulan' => $validated['garansi_bulan'],
            ]);

            // Sesuaikan unit fisik dengan target stok baru
            $this->servisStok->sesuaikanUnitKeTarget($produk, (int) $validated['stok']);
        });

        return Respons::sukses($produk->fresh(), 'Produk berhasil diubah', 200);
    }

    /**
     * DELETE /api/produk/{id} (Soft Delete & 409 guard)
     */
    public function destroy(int $id): JsonResponse
    {
        $produk = Produk::find($id);

        if (! $produk) {
            return Respons::gagal('Produk tidak ditemukan', 404);
        }

        // Periksa apakah produk ada pada pesanan aktif
        $idPesananAktif = DetailPesanan::where('produk_id', $id)
            ->whereHas('pesanan', function ($q) {
                $q->whereNotIn('status', ['selesai', 'dibatalkan']);
            })
            ->exists();

        if ($idPesananAktif) {
            return Respons::gagal('Produk tidak dapat dihapus karena masih ada pada pesanan yang berjalan', 409);
        }

        DB::transaction(function () use ($produk) {
            $produk->delete(); // Soft delete
            Keranjang::where('produk_id', $produk->id)->delete();
        });

        return Respons::sukses(null, 'Produk berhasil dihapus', 200);
    }
}
