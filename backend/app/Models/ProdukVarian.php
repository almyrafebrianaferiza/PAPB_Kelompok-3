<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProdukVarian extends Model
{
    protected $table = 'produk_varian';

    protected $fillable = [
        'produk_id',
        'nama_varian',
        'harga',
        'stok',
        'berat_gram',
        'sku',
    ];

    protected $casts = [
        'harga' => 'integer',
        'stok' => 'integer',
        'berat_gram' => 'integer',
    ];

    public function produk(): BelongsTo
    {
        return $this->belongsTo(Produk::class, 'produk_id');
    }
}
