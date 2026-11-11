<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Produk extends Model
{
    use SoftDeletes;

    protected $table = 'produk';

    protected $fillable = [
        'nama',
        'merek',
        'harga',
        'kategori',
        'stok',
        'tersedia',
        'deskripsi',
        'berat_gram',
        'garansi_bulan',
    ];

    protected $casts = [
        'harga' => 'integer',
        'stok' => 'integer',
        'tersedia' => 'boolean',
        'berat_gram' => 'integer',
        'garansi_bulan' => 'integer',
        'deleted_at' => 'datetime',
    ];

    public function unit(): HasMany
    {
        return $this->hasMany(UnitProduk::class, 'produk_id');
    }

    public function detailPesanan(): HasMany
    {
        return $this->hasMany(DetailPesanan::class, 'produk_id');
    }

    public function keranjang(): HasMany
    {
        return $this->hasMany(Keranjang::class, 'produk_id');
    }

    public function varian(): HasMany
    {
        return $this->hasMany(ProdukVarian::class, 'produk_id');
    }
}
