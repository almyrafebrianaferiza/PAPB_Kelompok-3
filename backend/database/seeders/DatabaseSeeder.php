<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Menjalankan seluruh seeder resmi Zenvorā secara berurutan.
     */
    public function run(): void
    {
        $this->call([
            PelangganSeeder::class,
            KurirSeeder::class,
            MetodePembayaranSeeder::class,
            ProdukSeeder::class,
            PesananContohSeeder::class,
        ]);
    }
}
