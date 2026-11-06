<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('produk', function (Blueprint $table) {
            $table->id();
            $table->string('nama', 150);
            $table->string('merek', 60);
            $table->unsignedInteger('harga');
            $table->string('kategori', 30)->index();
            $table->unsignedInteger('stok')->default(0);
            $table->boolean('tersedia')->default(true);
            $table->text('deskripsi')->nullable();
            $table->unsignedInteger('berat_gram');
            $table->unsignedSmallInteger('garansi_bulan');
            $table->softDeletes();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('produk');
    }
};
