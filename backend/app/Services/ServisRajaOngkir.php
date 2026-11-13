<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ServisRajaOngkir
{
    /**
     * Kota asal pengiriman toko (default: 256 = Kota Malang, Jawa Timur)
     */
    protected int $kotaAsalId;

    protected ?string $apiKey;

    public function __construct()
    {
        $this->kotaAsalId = (int) env('RAJAONGKIR_ORIGIN_KOTA', 256);
        $this->apiKey = env('RAJAONGKIR_API_KEY');
    }

    /**
     * Daftar kota populer Indonesia dengan ID resmi RajaOngkir (Starter)
     */
    public function ambilDaftarKota(): array
    {
        if (! empty($this->apiKey)) {
            try {
                $response = Http::withHeaders(['key' => $this->apiKey])
                    ->timeout(4)
                    ->get('https://api.rajaongkir.com/starter/city');

                if ($response->successful()) {
                    $results = $response->json('rajaongkir.results') ?? [];

                    return array_map(function ($c) {
                        return [
                            'city_id' => (int) $c['city_id'],
                            'province' => $c['province'],
                            'city_name' => $c['city_name'],
                            'type' => $c['type'],
                            'postal_code' => $c['postal_code'],
                            'label' => "{$c['type']} {$c['city_name']}, {$c['province']}",
                        ];
                    }, $results);
                }
            } catch (\Throwable $e) {
                Log::warning('RajaOngkir city fetch fallback: '.$e->getMessage());
            }
        }

        // Fallback kota-kota representatif Indonesia
        return [
            ['city_id' => 256, 'province' => 'Jawa Timur', 'city_name' => 'Malang', 'type' => 'Kota', 'postal_code' => '65111', 'label' => 'Kota Malang, Jawa Timur'],
            ['city_id' => 444, 'province' => 'Jawa Timur', 'city_name' => 'Surabaya', 'type' => 'Kota', 'postal_code' => '60119', 'label' => 'Kota Surabaya, Jawa Timur'],
            ['city_id' => 152, 'province' => 'DKI Jakarta', 'city_name' => 'Jakarta Pusat', 'type' => 'Kota', 'postal_code' => '10110', 'label' => 'Kota Jakarta Pusat, DKI Jakarta'],
            ['city_id' => 23, 'province' => 'Jawa Barat', 'city_name' => 'Bandung', 'type' => 'Kota', 'postal_code' => '40111', 'label' => 'Kota Bandung, Jawa Barat'],
            ['city_id' => 409, 'province' => 'Jawa Tengah', 'city_name' => 'Semarang', 'type' => 'Kota', 'postal_code' => '50135', 'label' => 'Kota Semarang, Jawa Tengah'],
            ['city_id' => 501, 'province' => 'DI Yogyakarta', 'city_name' => 'Yogyakarta', 'type' => 'Kota', 'postal_code' => '55111', 'label' => 'Kota Yogyakarta, DI Yogyakarta'],
            ['city_id' => 114, 'province' => 'Bali', 'city_name' => 'Denpasar', 'type' => 'Kota', 'postal_code' => '80111', 'label' => 'Kota Denpasar, Bali'],
            ['city_id' => 278, 'province' => 'Sumatera Utara', 'city_name' => 'Medan', 'type' => 'Kota', 'postal_code' => '20111', 'label' => 'Kota Medan, Sumatera Utara'],
            ['city_id' => 254, 'province' => 'Sulawesi Selatan', 'city_name' => 'Makassar', 'type' => 'Kota', 'postal_code' => '90111', 'label' => 'Kota Makassar, Sulawesi Selatan'],
            ['city_id' => 399, 'province' => 'Kalimantan Timur', 'city_name' => 'Samarinda', 'type' => 'Kota', 'postal_code' => '75111', 'label' => 'Kota Samarinda, Kalimantan Timur'],
            ['city_id' => 327, 'province' => 'Sumatera Selatan', 'city_name' => 'Palembang', 'type' => 'Kota', 'postal_code' => '30111', 'label' => 'Kota Palembang, Sumatera Selatan'],
            ['city_id' => 39, 'province' => 'Kepulauan Riau', 'city_name' => 'Batam', 'type' => 'Kota', 'postal_code' => '29411', 'label' => 'Kota Batam, Kepulauan Riau'],
        ];
    }

    /**
     * Hitung ongkir dinamis via RajaOngkir API atau kalkulasi berjenjang
     */
    public function hitungTarif(int $tujuanKotaId, int $totalBeratGram): array
    {
        $beratKg = (int) max(1, ceil($totalBeratGram / 1000));
        $beratGramTertagih = max(1000, $totalBeratGram);

        if (! empty($this->apiKey)) {
            $hasilApi = [];
            foreach (['jne', 'pos', 'tiki'] as $kurirKode) {
                try {
                    $res = Http::withHeaders(['key' => $this->apiKey])
                        ->timeout(3)
                        ->post('https://api.rajaongkir.com/starter/cost', [
                            'origin' => $this->kotaAsalId,
                            'destination' => $tujuanKotaId,
                            'weight' => $beratGramTertagih,
                            'courier' => $kurirKode,
                        ]);

                    if ($res->successful()) {
                        $courierData = $res->json('rajaongkir.results.0');
                        if ($courierData) {
                            foreach ($courierData['costs'] as $service) {
                                $biaya = $service['cost'][0]['value'] ?? 0;
                                $estimasi = $service['cost'][0]['etd'] ?? '-';
                                $hasilApi[] = [
                                    'nama' => strtoupper($kurirKode).' '.$service['service'],
                                    'wilayah' => "Estimasi $estimasi hari",
                                    'tarif_per_kg' => (int) round($biaya / $beratKg),
                                    'ongkir' => (int) $biaya,
                                    'berat_kg_tertagih' => $beratKg,
                                ];
                            }
                        }
                    }
                } catch (\Throwable $e) {
                    Log::warning("RajaOngkir cost calculation error for $kurirKode: ".$e->getMessage());
                }
            }

            if (! empty($hasilApi)) {
                return $hasilApi;
            }
        }

        // Kalkulasi dinamis berbasis wilayah kota tujuan (Mock RajaOngkir)
        $biayaDasarPerKg = match ($tujuanKotaId) {
            256 => 8000,      // Malang (Lokal)
            444 => 12000,     // Surabaya (Jawa Timur)
            152, 23, 409, 501 => 18000, // DKI Jakarta, Bandung, Semarang, Yogya (Pulau Jawa)
            114 => 22000,     // Bali
            278, 327, 39 => 32000, // Sumatera
            254 => 38000,     // Sulawesi
            399 => 42000,     // Kalimantan
            default => 25000, // Luar Pulau / Wilayah Lain
        };

        return [
            [
                'nama' => 'JNE Reguler (REG)',
                'wilayah' => 'Estimasi 2-3 hari',
                'tarif_per_kg' => $biayaDasarPerKg,
                'ongkir' => $biayaDasarPerKg * $beratKg,
                'berat_kg_tertagih' => $beratKg,
            ],
            [
                'nama' => 'JNE Express (YES)',
                'wilayah' => 'Estimasi 1 hari (Yakin Esok Sampai)',
                'tarif_per_kg' => (int) round($biayaDasarPerKg * 1.6),
                'ongkir' => (int) round($biayaDasarPerKg * 1.6) * $beratKg,
                'berat_kg_tertagih' => $beratKg,
            ],
            [
                'nama' => 'SiCepat BEST',
                'wilayah' => 'Estimasi 1-2 hari',
                'tarif_per_kg' => (int) round($biayaDasarPerKg * 1.3),
                'ongkir' => (int) round($biayaDasarPerKg * 1.3) * $beratKg,
                'berat_kg_tertagih' => $beratKg,
            ],
            [
                'nama' => 'POS Indonesia Kilat Khusus',
                'wilayah' => 'Estimasi 2-4 hari',
                'tarif_per_kg' => (int) round($biayaDasarPerKg * 0.9),
                'ongkir' => (int) round($biayaDasarPerKg * 0.9) * $beratKg,
                'berat_kg_tertagih' => $beratKg,
            ],
        ];
    }
}
