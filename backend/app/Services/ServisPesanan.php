<?php

namespace App\Services;

use App\Enums\StatusPesanan;
use App\Exceptions\BentrokException;
use App\Models\Pesanan;
use Illuminate\Support\Facades\DB;

class ServisPesanan
{
    public function __construct(
        protected ServisStok $servisStok
    ) {}

    public function ubahStatus(int $pesananId, string $statusBaruNilai): Pesanan
    {
        $pesanan = Pesanan::findOrFail($pesananId);
        $statusSekarang = StatusPesanan::from($pesanan->status);
        $statusBaru = StatusPesanan::tryFrom($statusBaruNilai);

        if (!$statusBaru || !$statusSekarang->bolehPindahKe($statusBaru)) {
            throw new BentrokException(
                "Pesanan berstatus {$pesanan->status} tidak dapat dipindah ke {$statusBaruNilai}"
            );
        }

        return DB::transaction(function () use ($pesanan, $statusBaru) {
            $pesanan->update(['status' => $statusBaru->value]);

            // Jika pesanan dibatalkan, kembalikan unit fisik serial ke status 'tersedia' dan sinkronkan stok
            if ($statusBaru === StatusPesanan::Dibatalkan) {
                foreach ($pesanan->detail as $detail) {
                    $this->servisStok->kembalikanUnit($detail->id);
                }
            }

            return $pesanan->load('detail.unit', 'kurir', 'metodePembayaran');
        });
    }

    public function formatRincian(Pesanan $pesanan): array
    {
        $statusEnum = StatusPesanan::from($pesanan->status);
        $statusBerikutnya = array_map(fn($s) => $s->value, $statusEnum->berikutnya());

        $items = $pesanan->detail->map(function ($d) {
            return [
                'id' => $d->id,
                'produk_id' => $d->produk_id,
                'nama_produk' => $d->nama_produk,
                'harga_satuan' => $d->harga_satuan,
                'jumlah' => $d->jumlah,
                'subtotal_item' => $d->subtotal_item,
                'berat_gram_satuan' => $d->berat_gram_satuan,
                'garansi_bulan' => $d->garansi_bulan,
                'nomor_seri' => $d->unit->pluck('nomor_seri')->values()->toArray(),
            ];
        });

        return [
            'id' => $pesanan->id,
            'nomor_pesanan' => $pesanan->nomor_pesanan,
            'status' => $pesanan->status,
            'status_berikutnya' => $statusBerikutnya,
            'nama_penerima' => $pesanan->nama_penerima,
            'alamat_penerima' => $pesanan->alamat_penerima,
            'kurir' => [
                'nama' => $pesanan->kurir?->nama,
                'wilayah' => $pesanan->kurir?->wilayah,
                'tarif_per_kg' => $pesanan->tarif_per_kg_saat_pesan,
            ],
            'metode_pembayaran' => [
                'kode' => $pesanan->metodePembayaran?->kode,
                'nama' => $pesanan->metodePembayaran?->nama,
            ],
            'subtotal' => $pesanan->subtotal,
            'total_berat_gram' => $pesanan->total_berat_gram,
            'berat_kg_tertagih' => $pesanan->berat_kg_tertagih,
            'ongkir' => $pesanan->ongkir,
            'total' => $pesanan->total,
            'item' => $items,
            'dibuat_pada' => $pesanan->created_at->toISOString(),
        ];
    }
}
