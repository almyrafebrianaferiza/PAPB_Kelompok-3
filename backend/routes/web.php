<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PesananController;
use App\Http\Middleware\PastikanAdmin;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')->name('admin.')->group(function (): void {
    Route::get('masuk', [AuthController::class, 'formulir'])->name('masuk');
    Route::post('masuk', [AuthController::class, 'masuk'])->name('masuk.proses');

    Route::middleware(PastikanAdmin::class)->group(function (): void {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        Route::get('pesanan', [PesananController::class, 'index'])->name('pesanan.index');
        Route::get('pesanan/{pesanan}', [PesananController::class, 'show'])->name('pesanan.show');
        Route::post('pesanan/{pesanan}/status', [PesananController::class, 'ubahStatus'])->name('pesanan.status');
        Route::post('pesanan/{pesanan}/resi', [PesananController::class, 'simpanResi'])->name('pesanan.resi');

        Route::post('keluar', [AuthController::class, 'keluar'])->name('keluar');
    });
});
