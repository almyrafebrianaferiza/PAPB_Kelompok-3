<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UnitProduk extends Model
{
    protected $table = 'unit_produk';

    protected $fillable = [
        'produk_id',
        'nomor_seri',
        'status',
        'detail_pesanan_id',
    ];

    public function produk(): BelongsTo
    {
        return $this->belongsTo(Produk::class, 'produk_id');
    }

    public function detailPesanan(): BelongsTo
    {
        return $this->belongsTo(DetailPesanan::class, 'detail_pesanan_id');
    }
}
