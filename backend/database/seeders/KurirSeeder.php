<?php

namespace Database\Seeders;

use App\Models\Kurir;
use Illuminate\Database\Seeder;

class KurirSeeder extends Seeder
{
    public function run(): void
    {
        $kurirs = [
            ['id' => 1, 'nama' => 'Zenvora Kota', 'wilayah' => 'Sidoarjo dan Surabaya', 'tarif_per_kg' => 4000, 'aktif' => true],
            ['id' => 2, 'nama' => 'Zenvora Jawa', 'wilayah' => 'Jawa Timur lainnya', 'tarif_per_kg' => 7500, 'aktif' => true],
            ['id' => 3, 'nama' => 'Zenvora Nusantara', 'wilayah' => 'Luar Jawa Timur', 'tarif_per_kg' => 15000, 'aktif' => true],
        ];

        foreach ($kurirs as $k) {
            Kurir::updateOrCreate(['id' => $k['id']], $k);
        }
    }
}
