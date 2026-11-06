<?php

namespace App\Services;

use App\Models\Kurir;
use Illuminate\Support\Collection;

class ServisOngkir
{
    /**
     * Menghitung subtotal, total berat, kg tertagih, ongkir, dan total pesanan.
     *
     * Rumus resmi domain Elektronik & Gawai:
     * total_berat_gram  = Σ (berat_gram_satuan × jumlah)
     * berat_kg_tertagih = ceil(total_berat_gram / 1000)
     * ongkir            = berat_kg_tertagih × tarif_per_kg_kurir
     * total             = subtotal + ongkir
     */
    public function hitung(Collection $keranjang, Collection $produkMap, int $kurirId): array
    {
        $kurir = Kurir::where('id', $kurirId)->where('aktif', true)->firstOrFail();

        $subtotal = 0;
        $totalBeratGram = 0;

        foreach ($keranjang as $item) {
            $prod = $produkMap->get($item->produk_id);
            if ($prod) {
                $subtotalItem = $prod->harga * $item->jumlah;
                $subtotal += $subtotalItem;
                $totalBeratGram += $prod->berat_gram * $item->jumlah;
            }
        }

        $beratKgTertagih = (int) ceil($totalBeratGram / 1000);
        $ongkir = $beratKgTertagih * $kurir->tarif_per_kg;
        $total = $subtotal + $ongkir;

        return [
            'subtotal' => $subtotal,
            'total_berat_gram' => $totalBeratGram,
            'berat_kg_tertagih' => $beratKgTertagih,
            'tarif_per_kg' => $kurir->tarif_per_kg,
            'ongkir' => $ongkir,
            'total' => $total,
            'kurir' => $kurir,
        ];
    }
}
