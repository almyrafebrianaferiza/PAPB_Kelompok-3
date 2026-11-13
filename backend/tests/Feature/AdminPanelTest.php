<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'admin.email' => 'admin@zenvora.test',
            'admin.password' => 'rahasia123',
        ]);
    }

    public function test_tamu_diarahkan_ke_halaman_masuk(): void
    {
        $this->get('/admin')->assertRedirect(route('admin.masuk'));
    }

    public function test_halaman_masuk_dapat_dibuka(): void
    {
        $this->get('/admin/masuk')
            ->assertOk()
            ->assertSee('Masuk Panel Penjual');
    }

    public function test_admin_dapat_masuk_dan_melihat_dashboard(): void
    {
        $response = $this->post('/admin/masuk', [
            'email' => 'admin@zenvora.test',
            'password' => 'rahasia123',
        ]);

        $response->assertRedirect(route('admin.dashboard'));
        $this->assertTrue(session('admin_terautentikasi'));

        $this->get('/admin')
            ->assertOk()
            ->assertSee('Dashboard')
            ->assertSee('Omzet Selesai');
    }

    public function test_kredensial_salah_ditolak(): void
    {
        $response = $this->from('/admin/masuk')->post('/admin/masuk', [
            'email' => 'admin@zenvora.test',
            'password' => 'salah-total',
        ]);

        $response->assertRedirect('/admin/masuk');
        $response->assertSessionHasErrors('email');
        $this->assertFalse(session('admin_terautentikasi', false));
    }

    public function test_admin_dapat_keluar(): void
    {
        $response = $this->withSession(['admin_terautentikasi' => true])
            ->post('/admin/keluar');

        $response->assertRedirect(route('admin.masuk'));

        $this->get('/admin')->assertRedirect(route('admin.masuk'));
    }
}
