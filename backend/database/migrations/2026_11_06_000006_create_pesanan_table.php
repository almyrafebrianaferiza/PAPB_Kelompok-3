<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pesanan', function (Blueprint $table) {
            $table->id();
            $table->string('nomor_pesanan', 30)->unique()->nullable();
            $table->foreignId('pelanggan_id')->constrained('pelanggan');
            $table->foreignId('kurir_id')->constrained('kurir');
            $table->foreignId('metode_pembayaran_id')->constrained('metode_pembayaran');
            $table->string('status', 25)->index();
            $table->string('nama_penerima', 100);
            $table->text('alamat_penerima');
            $table->unsignedInteger('subtotal');
            $table->unsignedInteger('total_berat_gram');
            $table->unsignedInteger('berat_kg_tertagih');
            $table->unsignedInteger('tarif_per_kg_saat_pesan');
            $table->unsignedInteger('ongkir');
            $table->unsignedInteger('total');
            $table->string('kunci_idempoten', 100);
            $table->unique(['pelanggan_id', 'kunci_idempoten']);
            $table->index(['pelanggan_id', 'created_at']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pesanan');
    }
};
