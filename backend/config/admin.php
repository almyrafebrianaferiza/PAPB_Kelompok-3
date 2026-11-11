<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Kredensial Admin Web
    |--------------------------------------------------------------------------
    |
    | Admin web Zenvora menggunakan sesi web (bukan token API mobile).
    | Kredensial disimpan di konfigurasi agar tidak menambah tabel baru
    | dan tidak mengubah skema basis data yang sudah disepakati.
    |
    */

    'email' => env('ADMIN_EMAIL', 'admin@zenvora.test'),

    'password' => env('ADMIN_PASSWORD', 'zenvora2026'),

    'nama' => env('ADMIN_NAMA', 'Administrator Zenvora'),

];
