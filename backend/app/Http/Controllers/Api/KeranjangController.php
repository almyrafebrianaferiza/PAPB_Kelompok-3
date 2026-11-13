<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\TambahKeranjangRequest;
use App\Http\Requests\UbahKeranjangRequest;
use App\Models\Keranjang;
use App\Models\Produk;
use App\Support\Respons;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KeranjangController extends Controller
{
    /**
     * GET /api/keranjang (Menghasilkan subtotal dan total unit dari server)
     */
    public function index(Request $request): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');

        $keranjangItems = Keranjang::with('produk')
            ->where('pelanggan_id', $pelanggan->id)
            ->get();

        $subtotal = 0;
        $totalJumlah = 0;

        $items = $keranjangItems->map(function ($item) use (&$subtotal, &$totalJumlah) {
            $prod = $item->produk;
            $subtotalItem = ($prod ? $prod->harga : 0) * $item->jumlah;
            $subtotal += $subtotalItem;
            $totalJumlah += $item->jumlah;

            return [
                'id' => $item->id,
                'produk_id' => $item->produk_id,
                'nama' => $prod?->nama ?? 'Produk Tidak Ditemukan',
                'merek' => $prod?->merek ?? '',
                'harga_satuan' => $prod?->harga ?? 0,
                'jumlah' => $item->jumlah,
                'berat_gram_satuan' => $prod?->berat_gram ?? 0,
                'subtotal_item' => $subtotalItem,
                'stok' => $prod?->stok ?? 0,
                'tersedia' => $prod ? $prod->tersedia && ! $prod->trashed() : false,
            ];
        });

        return Respons::sukses([
            'item' => $items,
            'total_jumlah' => $totalJumlah,
            'subtotal' => $subtotal,
        ], 'Keranjang berhasil diambil', 200);
    }

    /**
     * POST /api/keranjang
     */
    public function store(TambahKeranjangRequest $request): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');
        $validated = $request->validated();

        $produk = Produk::find($validated['produk_id']);

        if (! $produk->tersedia || $produk->stok <= 0) {
            return Respons::gagal("Produk {$produk->nama} saat ini tidak tersedia atau stok habis", 409);
        }

        $itemKeranjang = Keranjang::where('pelanggan_id', $pelanggan->id)
            ->where('produk_id', $produk->id)
            ->first();

        $jumlahBaru = ($itemKeranjang ? $itemKeranjang->jumlah : 0) + $validated['jumlah'];

        if ($jumlahBaru > $produk->stok) {
            return Respons::gagal("Stok {$produk->nama} tidak mencukupi (tersisa {$produk->stok})", 409);
        }

        $kodeStatus = 200;
        if ($itemKeranjang) {
            $itemKeranjang->update(['jumlah' => $jumlahBaru]);
        } else {
            $itemKeranjang = Keranjang::create([
                'pelanggan_id' => $pelanggan->id,
                'produk_id' => $produk->id,
                'jumlah' => $jumlahBaru,
            ]);
            $kodeStatus = 201;
        }

        $data = [
            'id' => $itemKeranjang->id,
            'produk_id' => $produk->id,
            'nama' => $produk->nama,
            'merek' => $produk->merek,
            'harga_satuan' => $produk->harga,
            'jumlah' => $itemKeranjang->jumlah,
            'berat_gram_satuan' => $produk->berat_gram,
            'subtotal_item' => $produk->harga * $itemKeranjang->jumlah,
            'stok' => $produk->stok,
            'tersedia' => $produk->tersedia,
        ];

        return Respons::sukses($data, 'Produk ditambahkan ke keranjang', $kodeStatus);
    }

    /**
     * PUT /api/keranjang/{id}
     */
    public function update(UbahKeranjangRequest $request, int $id): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');
        $validated = $request->validated();

        $itemKeranjang = Keranjang::where('id', $id)
            ->where('pelanggan_id', $pelanggan->id)
            ->first();

        if (! $itemKeranjang) {
            return Respons::gagal('Item keranjang tidak ditemukan', 404);
        }

        $produk = $itemKeranjang->produk;
        if (! $produk || ! $produk->tersedia) {
            return Respons::gagal('Produk tidak tersedia', 409);
        }

        if ($validated['jumlah'] > $produk->stok) {
            return Respons::gagal("Stok {$produk->nama} tidak mencukupi (tersisa {$produk->stok})", 409);
        }

        $itemKeranjang->update(['jumlah' => $validated['jumlah']]);

        $data = [
            'id' => $itemKeranjang->id,
            'produk_id' => $produk->id,
            'nama' => $produk->nama,
            'merek' => $produk->merek,
            'harga_satuan' => $produk->harga,
            'jumlah' => $itemKeranjang->jumlah,
            'berat_gram_satuan' => $produk->berat_gram,
            'subtotal_item' => $produk->harga * $itemKeranjang->jumlah,
            'stok' => $produk->stok,
            'tersedia' => $produk->tersedia,
        ];

        return Respons::sukses($data, 'Item keranjang diperbarui', 200);
    }

    /**
     * DELETE /api/keranjang/{id}
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $pelanggan = $request->attributes->get('pelanggan');

        $itemKeranjang = Keranjang::where('id', $id)
            ->where('pelanggan_id', $pelanggan->id)
            ->first();

        if (! $itemKeranjang) {
            return Respons::gagal('Item keranjang tidak ditemukan', 404);
        }

        $itemKeranjang->delete();

        return Respons::sukses(null, 'Item dihapus dari keranjang', 200);
    }
}
