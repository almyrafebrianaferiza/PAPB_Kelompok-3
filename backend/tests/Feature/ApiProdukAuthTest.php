<?php

namespace Tests\Feature;

use App\Models\Produk;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiProdukAuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();
    }

    private function sebagaiPembeli(): static
    {
        return $this->withHeader(
            'Authorization',
            'Bearer '.config('zenvora.token_pembeli')
        );
    }

    private function sebagaiAdmin(): static
    {
        return $this->withHeader(
            'Authorization',
            'Bearer '.config('zenvora.token_admin')
        );
    }

    private function payloadProduk(Produk $produk, string $nama): array
    {
        return [
            'nama' => $nama,
            'merek' => $produk->merek,
            'harga' => $produk->harga,
            'stok' => $produk->stok,
            'berat_gram' => $produk->berat_gram,
            'garansi_bulan' => $produk->garansi_bulan,
            'kategori' => $produk->kategori,
            'deskripsi' => $produk->deskripsi,
        ];
    }

    public function test_token_pembeli_dapat_membaca_produk(): void
    {
        $this->sebagaiPembeli()
            ->getJson('/api/produk/1')
            ->assertOk()
            ->assertJsonPath('status', 'sukses');
    }

    public function test_token_pembeli_ditolak_pada_seluruh_mutasi_produk(): void
    {
        $produk = Produk::findOrFail(1);
        $payload = $this->payloadProduk($produk, 'Tidak Boleh Diubah');

        $this->sebagaiPembeli()->postJson('/api/produk', $payload)->assertForbidden();
        $this->sebagaiPembeli()->putJson('/api/produk/1', $payload)->assertForbidden();
        $this->sebagaiPembeli()->deleteJson('/api/produk/1')->assertForbidden();

        $this->assertSame($produk->nama, Produk::findOrFail(1)->nama);
        $this->assertNull(Produk::withTrashed()->find(1)->deleted_at);
    }

    public function test_token_admin_dapat_mengubah_produk(): void
    {
        $produk = Produk::findOrFail(1);
        $payload = $this->payloadProduk($produk, 'Nama Produk Versi Admin');

        $this->sebagaiAdmin()
            ->putJson('/api/produk/1', $payload)
            ->assertOk()
            ->assertJsonPath('status', 'sukses')
            ->assertJsonPath('data.nama', 'Nama Produk Versi Admin');

        $this->assertSame('Nama Produk Versi Admin', Produk::findOrFail(1)->nama);
    }

    public function test_token_admin_tidak_berlaku_di_luar_jalur_produk(): void
    {
        $this->sebagaiAdmin()
            ->getJson('/api/pesanan')
            ->assertForbidden()
            ->assertJsonPath('status', 'gagal');
    }

    public function test_token_tidak_dikenal_ditolak(): void
    {
        $this->withHeader('Authorization', 'Bearer token-salah-2026')
            ->getJson('/api/produk')
            ->assertUnauthorized()
            ->assertJsonPath('status', 'gagal');
    }
}
