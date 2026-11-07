<?php

namespace Database\Seeders;

use App\Models\Pelanggan;
use Illuminate\Database\Seeder;

class PelangganSeeder extends Seeder
{
    public function run(): void
    {
        Pelanggan::updateOrCreate(
            ['id' => 1],
            [
                'nama' => 'Pembeli Zenvora',
                'token_statis' => config('zenvora.token_pembeli'),
            ]
        );
    }
}
