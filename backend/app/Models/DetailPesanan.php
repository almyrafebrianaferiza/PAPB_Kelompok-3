<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DetailPesanan extends Model
{
    protected $table = 'detail_pesanan';

    protected $fillable = [
        'pesanan_id',
        'produk_id',
        'nama_produk',
        'harga_satuan',
        'jumlah',
        'berat_gram_satuan',
        'garansi_bulan',
        'subtotal_item',
    ];

    protected $casts = [
        'harga_satuan' => 'integer',
        'jumlah' => 'integer',
        'berat_gram_satuan' => 'integer',
        'garansi_bulan' => 'integer',
        'subtotal_item' => 'integer',
    ];

    public function pesanan(): BelongsTo
    {
        return $this->belongsTo(Pesanan::class, 'pesanan_id');
    }

    public function produk(): BelongsTo
    {
        return $this->belongsTo(Produk::class, 'produk_id');
    }

    public function unit(): HasMany
    {
        return $this->hasMany(UnitProduk::class, 'detail_pesanan_id');
    }
}
