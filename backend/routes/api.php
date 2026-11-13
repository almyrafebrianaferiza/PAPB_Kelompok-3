<?php

use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\KurirController;
use App\Http\Controllers\Api\MetodePembayaranController;
use App\Http\Controllers\Api\PesananController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Middleware\AutentikasiTokenStatis;
use App\Http\Middleware\MiddlewareDemo;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| REST API Routes Toko Online Zenvorā (15 Endpoint Resmi)
|--------------------------------------------------------------------------
*/

Route::middleware([MiddlewareDemo::class, AutentikasiTokenStatis::class])->group(function () {
    // 1-5: Operasi CRUD Produk
    Route::get('/produk', [ProdukController::class, 'index']);
    Route::get('/produk/{id}', [ProdukController::class, 'show']);
    Route::post('/produk', [ProdukController::class, 'store']);
    Route::put('/produk/{id}', [ProdukController::class, 'update']);
    Route::delete('/produk/{id}', [ProdukController::class, 'destroy']);

    // 6-9: Keranjang Belanja
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    Route::post('/keranjang', [KeranjangController::class, 'store']);
    Route::put('/keranjang/{id}', [KeranjangController::class, 'update']);
    Route::delete('/keranjang/{id}', [KeranjangController::class, 'destroy']);

    // 10: Kurir Internal & Estimasi Ongkos Kirim
    Route::get('/kurir', [KurirController::class, 'index']);

    // 11: Checkout Transaksional & Idempoten
    Route::post('/checkout', [CheckoutController::class, 'store']);

    // 12-14: Pesanan & Manajemen Status
    Route::get('/pesanan', [PesananController::class, 'index']);
    Route::get('/pesanan/{id}', [PesananController::class, 'show']);
    Route::patch('/pesanan/{id}/status', [PesananController::class, 'ubahStatus']);

    // 15: Metode Pembayaran Simulasi
    Route::get('/metode-pembayaran', [MetodePembayaranController::class, 'index']);
});
