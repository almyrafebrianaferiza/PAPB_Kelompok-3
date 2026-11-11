<?php

namespace Tests\Feature;

use App\Enums\StatusPesanan;
use App\Models\Pesanan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPesananTest extends TestCase
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

    public function test_tamu_tidak_dapat_melihat_daftar_pesanan(): void
    {
        $this->get(route('admin.pesanan.index'))->assertRedirect(route('admin.masuk'));
    }

    public function test_daftar_pesanan_dapat_dibuka_dan_difilter(): void
    {
        $this->sebagaiAdmin()
            ->get(route('admin.pesanan.index'))
            ->assertOk()
            ->assertSee('Pesanan Masuk')
            ->assertSee('ZNV-20261106-00001');

        $this->sebagaiAdmin()
            ->get(route('admin.pesanan.index', ['status' => StatusPesanan::Selesai->value]))
            ->assertOk()
            ->assertSee('ZNV-20261106-00003')
            ->assertDontSee('ZNV-20261106-00001');
    }

    public function test_rincian_pesanan_menampilkan_nomor_seri(): void
    {
        $unit = Pesanan::findOrFail(2)->detail()->first()->unit()->firstOrFail();

        $this->sebagaiAdmin()
            ->get(route('admin.pesanan.show', 2))
            ->assertOk()
            ->assertSee('ZNV-20261106-00002')
            ->assertSee($unit->nomor_seri);
    }

    public function test_transisi_status_sah_diproses(): void
    {
        $this->sebagaiAdmin()
            ->post(route('admin.pesanan.status', 1), ['status' => StatusPesanan::MenungguKonfirmasi->value])
            ->assertRedirect()
            ->assertSessionHasNoErrors();

        $this->assertSame(StatusPesanan::MenungguKonfirmasi->value, Pesanan::findOrFail(1)->status);
    }

    public function test_transisi_status_tidak_sah_ditolak(): void
    {
        $this->sebagaiAdmin()
            ->from(route('admin.pesanan.show', 1))
            ->post(route('admin.pesanan.status', 1), ['status' => StatusPesanan::Selesai->value])
            ->assertRedirect(route('admin.pesanan.show', 1))
            ->assertSessionHasErrors('status');

        $this->assertSame(StatusPesanan::MenungguPembayaran->value, Pesanan::findOrFail(1)->status);
    }

    public function test_input_resi_memindahkan_pesanan_ke_dikirim(): void
    {
        $this->sebagaiAdmin()
            ->post(route('admin.pesanan.status', 2), ['status' => StatusPesanan::Diproses->value])
            ->assertSessionHasNoErrors();

        $this->sebagaiAdmin()
            ->post(route('admin.pesanan.resi', 2), ['nomor_resi' => 'JNE1234567890'])
            ->assertSessionHasNoErrors();

        $pesanan = Pesanan::findOrFail(2);

        $this->assertSame(StatusPesanan::Dikirim->value, $pesanan->status);
        $this->assertSame('JNE1234567890', $pesanan->nomor_resi);
    }

    public function test_resi_ditolak_jika_status_belum_diproses(): void
    {
        $this->sebagaiAdmin()
            ->from(route('admin.pesanan.show', 1))
            ->post(route('admin.pesanan.resi', 1), ['nomor_resi' => 'JNE000'])
            ->assertRedirect(route('admin.pesanan.show', 1))
            ->assertSessionHasErrors('nomor_resi');

        $this->assertNull(Pesanan::findOrFail(1)->nomor_resi);
    }
}
