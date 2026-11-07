<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Kategori Produk Resmi
    |--------------------------------------------------------------------------
    | Nilai persis kontrak api-contract (Bagian 2.1). Digunakan oleh aturan
    | validasi SimpanProdukRequest.
    */

    'kategori' => ['gadget', 'laptop', 'tv', 'monitor', 'tablet'],

    /*
    |--------------------------------------------------------------------------
    | Token Statis Pembeli (pengembangan)
    |--------------------------------------------------------------------------
    | Nilai default dipakai PelangganSeeder untuk kolom pelanggan.token_statis.
    */

    'token_pembeli' => env('ZENVORA_TOKEN_PEMBELI', 'zenvora-dev-token-2026'),

    /*
    |--------------------------------------------------------------------------
    | Flag Demo Galat
    |--------------------------------------------------------------------------
    | Dibaca MiddlewareDemo untuk perekaman video demo E5.
    */

    'paksa_galat' => filter_var(env('ZENVORA_PAKSA_GALAT', false), FILTER_VALIDATE_BOOLEAN),

    'lambat_detik' => (int) env('ZENVORA_LAMBAT_DETIK', 0),

];
