<?php

namespace App\Http\Middleware;

use App\Support\Respons;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class MiddlewareDemo
{
    /**
     * Menyediakan pemicu galat terukur untuk keperluan perekaman video demo 5 jenis galat.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // 1. Simulasi Galat Server 500
        $paksaGalatEnv = filter_var(env('ZENVORA_PAKSA_GALAT', false), FILTER_VALIDATE_BOOLEAN);
        $headerGalat = $request->header('X-Demo-Error') === 'true';

        if ($paksaGalatEnv || $headerGalat) {
            return Respons::gagal('Terjadi kesalahan pada server', 500);
        }

        // 2. Simulasi Batas Waktu Terlampaui (Timeout > 10 detik)
        $lambatDetikEnv = (int) env('ZENVORA_LAMBAT_DETIK', 0);
        $headerDelay = (int) $request->header('X-Demo-Delay', 0);
        $delaySec = max($lambatDetikEnv, $headerDelay);

        if ($delaySec > 0) {
            sleep($delaySec);
        }

        return $next($request);
    }
}
