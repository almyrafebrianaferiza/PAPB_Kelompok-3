<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const GAMBAR_PRODUK = [
        5 => 'products/lenovo.png',
        6 => 'products/lenovo.png',
        7 => 'products/samsung.png',
        8 => 'products/apple.png',
        9 => 'products/apple.png',
        10 => 'products/apple.png',
        11 => 'products/apple.png',
        12 => 'products/samsung.png',
        13 => 'products/samsung.png',
        14 => 'products/xiaomi.png',
        15 => 'products/apple.png',
    ];

    public function up(): void
    {
        foreach (self::GAMBAR_PRODUK as $produkId => $gambarPath) {
            DB::table('produk')
                ->where('id', $produkId)
                ->update(['gambar_path' => $gambarPath]);
        }
    }

    public function down(): void
    {
        foreach (self::GAMBAR_PRODUK as $produkId => $gambarPath) {
            DB::table('produk')
                ->where('id', $produkId)
                ->where('gambar_path', $gambarPath)
                ->update(['gambar_path' => null]);
        }
    }
};
