<?php

namespace Tests\Feature;

use App\Models\Keranjang;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiKeranjangTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();
    }

    public function test_keranjang_mengirimkan_url_gambar_produk(): void
    {
        Keranjang::create([
            'pelanggan_id' => 1,
            'produk_id' => 1,
            'jumlah' => 1,
        ]);

        $this->withHeader(
            'Authorization',
            'Bearer '.config('zenvora.token_pembeli')
        )
            ->getJson('/api/keranjang')
            ->assertOk()
            ->assertJsonPath(
                'data.item.0.gambar_url',
                rtrim((string) config('app.url'), '/').'/api/storage/products/samsung.png'
            );
    }
}
