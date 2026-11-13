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
     * Menangani autentikasi token statis dan pembagian peran API:
     * - token admin: hanya jalur /api/produk (khususnya mutasi);
     * - token pembeli: seluruh rute, kecuali mutasi produk.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $authHeader = $request->header('Authorization');

        if (! $authHeader || ! str_starts_with($authHeader, 'Bearer ')) {
            return Respons::gagal('Token tidak valid atau tidak disertakan', 401);
        }

        $token = trim(substr($authHeader, 7));

        $tokenAdmin = config('zenvora.token_admin');
        if (is_string($tokenAdmin) && $tokenAdmin !== '' && hash_equals($tokenAdmin, $token)) {
            if (! $request->is('api/produk*')) {
                return Respons::gagal('Token admin hanya berlaku untuk jalur produk', 403);
            }

            $request->attributes->set('peran', 'admin');

            return $next($request);
        }

        $pelanggan = Pelanggan::where('token_statis', $token)->first();

        if (! $pelanggan) {
            return Respons::gagal('Token tidak valid', 401);
        }

        $mutasiProduk = in_array($request->method(), ['POST', 'PUT', 'DELETE'], true)
            && $request->is('api/produk*');

        if ($mutasiProduk) {
            return Respons::gagal('Mutasi produk hanya dapat dilakukan dengan token admin', 403);
        }

        // Simpan pelanggan aktif ke atribut request
        $request->attributes->set('pelanggan', $pelanggan);
        $request->attributes->set('peran', 'pembeli');

        return $next($request);
    }
}
