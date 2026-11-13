<?php

namespace App\Http\Middleware;

use App\Models\Pelanggan;
use App\Support\Respons;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AutentikasiTokenStatis
{
    /**
     * Menangani autentikasi token statis pembeli.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $authHeader = $request->header('Authorization');

        if (! $authHeader || ! str_starts_with($authHeader, 'Bearer ')) {
            return Respons::gagal('Token tidak valid atau tidak disertakan', 401);
        }

        $token = trim(substr($authHeader, 7));
        $pelanggan = Pelanggan::where('token_statis', $token)->first();

        if (! $pelanggan) {
            return Respons::gagal('Token tidak valid', 401);
        }

        // Simpan pelanggan aktif ke atribut request
        $request->attributes->set('pelanggan', $pelanggan);

        return $next($request);
    }
}
