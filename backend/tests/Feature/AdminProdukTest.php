<?php

namespace Tests\Feature;

use App\Models\Produk;
use App\Models\UnitProduk;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminProdukTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();
    }

    private function sebagaiAdmin(): static
    {
        return $this->withSession(['admin_terautentikasi' => true]);
    }

    private function dataProduk(array $tambahan = []): array
    {
        return array_merge([
            'nama' => 'Uji Produk Baru',
            'merek' => 'UjiMerek',
            'harga' => 1000000,
            'kategori' => 'gadget',
            'stok' => 2,
            'tersedia' => '1',
            'deskripsi' => 'Produk untuk pengujian.',
            'berat_gram' => 200,
            'garansi_bulan' => 12,
        ], $tambahan);
    }

    public function test_tamu_tidak_dapat_membuka_katalog_admin(): void
    {
        $this->get(route('admin.produk.index'))->assertRedirect(route('admin.masuk'));
    }

    public function test_katalog_menampilkan_produk(): void
    {
        $this->sebagaiAdmin()
            ->get(route('admin.produk.index'))
            ->assertOk()
            ->assertSee('Katalog Produk')
            ->assertSee('Samsung Galaxy A55 5G 8/256');
    }

    public function test_form_tambah_dan_ubah_produk_dapat_dibuka(): void
    {
        $this->sebagaiAdmin()
            ->get(route('admin.produk.create'))
            ->assertOk()
            ->assertSee('Tambah Produk');

        $this->sebagaiAdmin()
            ->get(route('admin.produk.edit', 1))
            ->assertOk()
            ->assertSee('Ubah Produk')
            ->assertSee('8GB / 256GB - Awesome Iceblue');
    }

    public function test_halaman_unit_serial_dapat_dibuka(): void
    {
        $unit = UnitProduk::firstOrFail();

        $this->sebagaiAdmin()
            ->get(route('admin.unit.index'))
            ->assertOk()
            ->assertSee('Unit &amp; Serial', false)
            ->assertSee($unit->nomor_seri);
    }

    public function test_produk_baru_menerima_gambar_produk(): void
    {
        Storage::fake('public');

        $this->sebagaiAdmin()
            ->post(route('admin.produk.store'), array_merge($this->dataProduk(), [
                'gambar' => UploadedFile::fake()->image('gadget.jpg', 800, 600),
            ]))
            ->assertRedirect()
            ->assertSessionHasNoErrors();

        $produk = Produk::where('nama', 'Uji Produk Baru')->firstOrFail();

        $this->assertNotNull($produk->gambar_path);
        Storage::disk('public')->assertExists($produk->gambar_path);
    }

    public function test_produk_baru_membuat_unit_serial_sesuai_stok(): void
    {
        $this->sebagaiAdmin()
            ->post(route('admin.produk.store'), $this->dataProduk())
            ->assertRedirect()
            ->assertSessionHasNoErrors();

        $produk = Produk::where('nama', 'Uji Produk Baru')->firstOrFail();

        $this->assertSame(2, $produk->stok);
        $this->assertSame(2, UnitProduk::where('produk_id', $produk->id)->count());
    }

    public function test_produk_baru_dengan_varian_mengikuti_total_stok_varian(): void
    {
        $this->sebagaiAdmin()
            ->post(route('admin.produk.store'), $this->dataProduk([
                'stok' => 99,
                'varian' => [
                    ['nama_varian' => '8GB / 128GB', 'harga' => 900000, 'stok' => 1, 'berat_gram' => 200, 'sku' => 'UJI-128'],
                    ['nama_varian' => '8GB / 256GB', 'harga' => 1100000, 'stok' => 3, 'berat_gram' => 200, 'sku' => 'UJI-256'],
                ],
            ]))
            ->assertSessionHasNoErrors();

        $produk = Produk::where('nama', 'Uji Produk Baru')->firstOrFail();

        $this->assertSame(2, $produk->varian()->count());
        $this->assertSame(4, $produk->stok);
        $this->assertSame(4, UnitProduk::where('produk_id', $produk->id)->count());
    }

    public function test_update_menyinkronkan_varian_dan_stok(): void
    {
        $produk = Produk::findOrFail(1);
        $varianDipertahankan = $produk->varian()->orderBy('id')->firstOrFail();

        $this->sebagaiAdmin()
            ->put(route('admin.produk.update', $produk), $this->dataProduk([
                'nama' => $produk->nama,
                'merek' => $produk->merek,
                'harga' => $produk->harga,
                'kategori' => $produk->kategori,
                'stok' => 0,
                'berat_gram' => $produk->berat_gram,
                'garansi_bulan' => $produk->garansi_bulan,
                'varian' => [
                    [
                        'id' => $varianDipertahankan->id,
                        'nama_varian' => 'Varian Tunggal',
                        'harga' => 5555000,
                        'stok' => 3,
                        'berat_gram' => 213,
                        'sku' => 'TUNGGAL-1',
                    ],
                ],
            ]))
            ->assertSessionHasNoErrors();

        $produk->refresh();

        $this->assertSame(1, $produk->varian()->count());
        $this->assertSame('Varian Tunggal', $produk->varian()->first()->nama_varian);
        $this->assertSame(3, $produk->stok);
        $this->assertSame(3, UnitProduk::where('produk_id', $produk->id)->where('status', 'tersedia')->count());
    }

    public function test_produk_dengan_pesanan_aktif_tidak_bisa_dihapus(): void
    {
        $this->sebagaiAdmin()
            ->from(route('admin.produk.index'))
            ->delete(route('admin.produk.destroy', 2))
            ->assertRedirect(route('admin.produk.index'))
            ->assertSessionHasErrors('produk');

        $this->assertNotNull(Produk::find(2));
    }

    public function test_produk_tanpa_pesanan_aktif_dapat_dihapus(): void
    {
        $this->sebagaiAdmin()
            ->delete(route('admin.produk.destroy', 15))
            ->assertRedirect(route('admin.produk.index'));

        $this->assertNull(Produk::find(15));
    }

    public function test_status_unit_dapat_diubah_dan_stok_tersinkron(): void
    {
        $unit = UnitProduk::where('produk_id', 15)->where('status', 'tersedia')->firstOrFail();
        $stokAwal = Produk::findOrFail(15)->stok;

        $this->sebagaiAdmin()
            ->post(route('admin.unit.status', $unit), ['status' => 'rusak'])
            ->assertSessionHasNoErrors();

        $this->assertSame('rusak', $unit->fresh()->status);
        $this->assertSame($stokAwal - 1, Produk::findOrFail(15)->stok);

        $this->sebagaiAdmin()
            ->post(route('admin.unit.status', $unit), ['status' => 'tersedia'])
            ->assertSessionHasNoErrors();

        $this->assertSame($stokAwal, Produk::findOrFail(15)->stok);
    }

    public function test_unit_terjual_tidak_dapat_diubah(): void
    {
        $unit = UnitProduk::where('status', 'terjual')->firstOrFail();

        $this->sebagaiAdmin()
            ->from(route('admin.unit.index'))
            ->post(route('admin.unit.status', $unit), ['status' => 'rusak'])
            ->assertRedirect(route('admin.unit.index'))
            ->assertSessionHasErrors('unit');

        $this->assertSame('terjual', $unit->fresh()->status);
    }
}
