<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Pesanan extends Model
{
    protected $table = 'pesanan';

    protected $fillable = [
        'nomor_pesanan',
        'pelanggan_id',
        'kurir_id',
        'metode_pembayaran_id',
        'status',
        'nama_penerima',
        'alamat_penerima',
        'subtotal',
        'total_berat_gram',
        'berat_kg_tertagih',
        'tarif_per_kg_saat_pesan',
        'ongkir',
        'total',
        'kunci_idempoten',
    ];

    protected $casts = [
        'subtotal' => 'integer',
        'total_berat_gram' => 'integer',
        'berat_kg_tertagih' => 'integer',
        'tarif_per_kg_saat_pesan' => 'integer',
        'ongkir' => 'integer',
        'total' => 'integer',
    ];

    public function pelanggan(): BelongsTo
    {
        return $this->belongsTo(Pelanggan::class, 'pelanggan_id');
    }

    public function kurir(): BelongsTo
    {
        return $this->belongsTo(Kurir::class, 'kurir_id');
    }

    public function metodePembayaran(): BelongsTo
    {
        return $this->belongsTo(MetodePembayaran::class, 'metode_pembayaran_id');
    }

    public function detail(): HasMany
    {
        return $this->hasMany(DetailPesanan::class, 'pesanan_id');
    }
}
