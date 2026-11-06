<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keranjang;
use App\Models\Kurir;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KurirController extends Controller
{
    /**
     * GET /api/kurir (Memuat ongkir dan estimasi total dinamis berdasarkan berat keranjang saat ini)
     */
    public function index(Request $request): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');
        $kurirs = Kurir::where('aktif', true)->orderBy('id', 'asc')->get();

        $cartItems = Keranjang::with('produk')->where('pelanggan_id', $pelanggan->id)->get();

        $totalBeratGram = 0;
        $subtotal = 0;

        foreach ($cartItems as $c) {
            if ($c->produk) {
                $totalBeratGram += $c->produk->berat_gram * $c->jumlah;
                $subtotal += $c->produk->harga * $c->jumlah;
            }
        }

        $beratKgTertagih = $totalBeratGram > 0 ? (int) ceil($totalBeratGram / 1000) : 0;

        $result = $kurirs->map(function ($k) use ($beratKgTertagih, $subtotal) {
            $ongkir = $beratKgTertagih * $k->tarif_per_kg;
            return [
                'id' => $k->id,
                'nama' => $k->nama,
                'wilayah' => $k->wilayah,
                'tarif_per_kg' => $k->tarif_per_kg,
                'berat_kg_tertagih' => $beratKgTertagih,
                'ongkir' => $ongkir,
                'total_estimasi' => $subtotal + $ongkir,
            ];
        });

        return Respons::sukses($result, 'Daftar kurir berhasil diambil', 200);
    }
}
