<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const GAMBAR_PRODUK = [
        1 => 'products/samsung.png',
        2 => 'products/xiaomi.png',
        3 => 'products/apple.png',
        4 => 'products/asus.png',
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
