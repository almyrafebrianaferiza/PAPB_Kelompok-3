<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keranjang;
use App\Models\Kurir;
use App\Services\ServisRajaOngkir;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KurirController extends Controller
{
    public function __construct(
        protected ServisRajaOngkir $rajaOngkir
    ) {}

    /**
     * GET /api/kurir (Daftar kota tujuan atau kurir aktif dengan estimasi ongkir keranjang)
     */
    public function index(Request $request): JsonResponse
    {
        // Fitur RajaOngkir: Ambil daftar kota tujuan pengiriman
        if ($request->query('opsi') === 'kota') {
            $kotaList = $this->rajaOngkir->ambilDaftarKota();

            return Respons::sukses($kotaList, 'Daftar kota pengiriman berhasil diambil', 200);
        }

        $pelanggan = $request->attributes->get('pelanggan');
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

        $kurirs = Kurir::where('aktif', true)->orderBy('id', 'asc')->get();

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
