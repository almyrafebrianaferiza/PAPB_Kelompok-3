<?php

namespace Tests\Feature;

use App\Models\Pelanggan;
use App\Models\Pesanan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiPesananTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();
    }

    private function sebagaiPembeli(?string $token = null): static
    {
        return $this->withHeader(
            'Authorization',
            'Bearer '.($token ?? config('zenvora.token_pembeli'))
        );
    }

    public function test_pembeli_dapat_mengonfirmasi_pembayaran(): void
    {
        $this->sebagaiPembeli()
            ->patchJson('/api/pesanan/1/status', ['status' => 'menunggu_konfirmasi'])
            ->assertOk()
            ->assertJsonPath('status', 'sukses')
            ->assertJsonPath('data.status', 'menunggu_konfirmasi');

        $this->assertSame('menunggu_konfirmasi', Pesanan::findOrFail(1)->status);
    }

    public function test_pembeli_tidak_dapat_menandai_pesanan_dibayar(): void
    {
        $this->sebagaiPembeli()
            ->patchJson('/api/pesanan/1/status', ['status' => 'dibayar'])
            ->assertForbidden()
            ->assertJsonPath('status', 'gagal');

        $this->assertSame('menunggu_pembayaran', Pesanan::findOrFail(1)->status);
    }

    public function test_pembeli_tidak_dapat_mengubah_pesanan_milik_pelanggan_lain(): void
    {
        Pelanggan::create([
            'id' => 2,
            'nama' => 'Pembeli Lain',
            'token_statis' => 'token-pembeli-lain-2026',
        ]);

        $this->sebagaiPembeli('token-pembeli-lain-2026')
            ->patchJson('/api/pesanan/1/status', ['status' => 'menunggu_konfirmasi'])
            ->assertNotFound();

        $this->assertSame('menunggu_pembayaran', Pesanan::findOrFail(1)->status);
    }
}
