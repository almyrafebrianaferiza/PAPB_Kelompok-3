<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('unit_produk', function (Blueprint $table) {
            $table->id();
            $table->foreignId('produk_id')->constrained('produk')->restrictOnDelete();
            $table->string('nomor_seri', 40)->unique();
            $table->string('status', 15)->default('tersedia');
            $table->foreignId('detail_pesanan_id')->nullable()->constrained('detail_pesanan')->nullOnDelete();
            $table->index(['produk_id', 'status']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('unit_produk');
    }
};
