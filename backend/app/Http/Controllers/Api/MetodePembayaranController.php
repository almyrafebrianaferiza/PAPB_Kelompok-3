<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MetodePembayaran;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;

class MetodePembayaranController extends Controller
{
    /**
     * GET /api/metode-pembayaran
     */
    public function index(): JsonResponse
    {
        $metode = MetodePembayaran::where('aktif', true)
            ->orderBy('id', 'asc')
            ->get(['id', 'kode', 'nama']);

        return Respons::sukses($metode, 'Daftar metode pembayaran berhasil diambil', 200);
    }
}
