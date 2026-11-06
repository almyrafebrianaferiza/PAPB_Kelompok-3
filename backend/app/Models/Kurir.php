<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Kurir extends Model
{
    protected $table = 'kurir';

    protected $fillable = [
        'nama',
        'wilayah',
        'tarif_per_kg',
        'aktif',
    ];

    protected $casts = [
        'tarif_per_kg' => 'integer',
        'aktif' => 'boolean',
    ];

    public function pesanan(): HasMany
    {
        return $this->hasMany(Pesanan::class, 'kurir_id');
    }
}
