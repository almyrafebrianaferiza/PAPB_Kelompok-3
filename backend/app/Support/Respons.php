<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;

class Respons
{
    /**
     * Membentuk respons sukses terstandarisasi.
     */
    public static function sukses(mixed $data = null, string $pesan = 'Operasi berhasil', int $kodeStatus = 200): JsonResponse
    {
        return response()->json([
            'status' => 'sukses',
            'code' => (string) $kodeStatus,
            'message' => $pesan,
            'data' => $data,
        ], $kodeStatus);
    }

    /**
     * Membentuk respons gagal terstandarisasi.
     */
    public static function gagal(
        string $pesan = 'Terjadi kesalahan',
        int $kodeStatus = 422,
        ?array $errors = null,
        mixed $data = null
    ): JsonResponse {
        $badan = [
            'status' => 'gagal',
            'code' => (string) $kodeStatus,
            'message' => $pesan,
        ];

        if ($kodeStatus === 422 && $errors !== null) {
            $badan['errors'] = $errors;
        }

        if ($data !== null) {
            $badan['data'] = $data;
        }

        return response()->json($badan, $kodeStatus);
    }
}
