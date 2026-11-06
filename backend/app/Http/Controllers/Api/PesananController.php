<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\BentrokException;
use App\Http\Controllers\Controller;
use App\Http\Requests\UbahStatusRequest;
use App\Models\Pesanan;
use App\Services\ServisPesanan;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PesananController extends Controller
{
    public function __construct(
        protected ServisPesanan $servisPesanan
    ) {}

    /**
     * GET /api/pesanan (Riwayat pesanan terurut dari yang terbaru)
     */
    public function index(Request $request): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');

        $pesanans = Pesanan::with('detail')
            ->where('pelanggan_id', $pelanggan->id)
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->get();

        $result = $pesanans->map(function ($p) {
            return [
                'id' => $p->id,
                'nomor_pesanan' => $p->nomor_pesanan,
                'status' => $p->status,
                'total' => $p->total,
                'jumlah_barang' => $p->detail->sum('jumlah'),
                'dibuat_pada' => $p->created_at->toISOString(),
            ];
        });

        return Respons::sukses($result, 'Daftar riwayat pesanan berhasil diambil', 200);
    }

    /**
     * GET /api/pesanan/{id} (Rincian lengkap beserta nomor seri unit fisik)
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');

        $pesanan = Pesanan::with(['detail.unit', 'kurir', 'metodePembayaran'])
            ->where('id', $id)
            ->where('pelanggan_id', $pelanggan->id)
            ->first();

        if (!$pesanan) {
            return Respons::gagal('Pesanan tidak ditemukan', 404);
        }

        $rincian = $this->servisPesanan->formatRincian($pesanan);

        return Respons::sukses($rincian, 'Rincian pesanan berhasil diambil', 200);
    }

    /**
     * PATCH /api/pesanan/{id}/status (Mengubah status sesuai aturan transisi yang sah)
     */
    public function ubahStatus(UbahStatusRequest $request, int $id): JsonResponse
    {
        $validated = $request->validated();

        try {
            $pesanan = $this->servisPesanan->ubahStatus($id, $validated['status']);
            $rincian = $this->servisPesanan->formatRincian($pesanan);

            return Respons::sukses($rincian, 'Status pesanan berhasil diperbarui', 200);
        } catch (BentrokException $e) {
            return Respons::gagal($e->getMessage(), 409);
        }
    }
}
