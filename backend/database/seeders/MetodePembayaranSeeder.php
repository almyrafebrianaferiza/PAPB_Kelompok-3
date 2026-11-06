<?php

namespace Database\Seeders;

use App\Models\MetodePembayaran;
use Illuminate\Database\Seeder;

class MetodePembayaranSeeder extends Seeder
{
    public function run(): void
    {
        $metodes = [
            ['id' => 1, 'kode' => 'tunai_di_tempat', 'nama' => 'Bayar Tunai di Tempat', 'aktif' => true],
            ['id' => 2, 'kode' => 'transfer_manual', 'nama' => 'Transfer Manual', 'aktif' => true],
        ];

        foreach ($metodes as $m) {
            MetodePembayaran::updateOrCreate(['id' => $m['id']], $m);
        }
    }
}
