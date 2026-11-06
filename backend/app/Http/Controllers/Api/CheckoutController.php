<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\BentrokException;
use App\Http\Controllers\Controller;
use App\Http\Requests\CheckoutRequest;
use App\Services\ServisCheckout;
use App\Services\ServisPesanan;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;

class CheckoutController extends Controller
{
    public function __construct(
        protected ServisCheckout $servisCheckout,
        protected ServisPesanan $servisPesanan
    ) {}

    /**
     * POST /api/checkout (Wajib menerima header X-Kunci-Idempoten)
     */
    public function store(CheckoutRequest $request): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');
        $kunciIdempoten = $request->header('X-Kunci-Idempoten');

        if (!$kunciIdempoten || strlen(trim($kunciIdempoten)) < 8) {
            return Respons::gagal('Header X-Kunci-Idempoten wajib disertakan', 422, [
                'kunci_idempoten' => ['Header X-Kunci-Idempoten wajib diisi (minimal 8 karakter)'],
            ]);
        }

        try {
            $pesanan = $this->servisCheckout->proses($pelanggan, trim($kunciIdempoten), $request->validated());
            $rincian = $this->servisPesanan->formatRincian($pesanan);

            return Respons::sukses($rincian, 'Pesanan berhasil dibuat', 201);
        } catch (BentrokException $e) {
            return Respons::gagal($e->getMessage(), 409, null, $e->getData());
        }
    }
}
