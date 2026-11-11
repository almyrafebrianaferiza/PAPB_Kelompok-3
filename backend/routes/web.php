<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
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
        Route::post('keluar', [AuthController::class, 'keluar'])->name('keluar');
    });
});
