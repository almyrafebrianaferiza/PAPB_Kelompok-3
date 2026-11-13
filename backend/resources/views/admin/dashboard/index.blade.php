@extends('admin.layouts.app')

@php
    $labelStatus = [
        'menunggu_pembayaran' => ['Menunggu Pembayaran', 'admin-badge-warning'],
        'menunggu_konfirmasi' => ['Menunggu Konfirmasi', 'admin-badge-warning'],
        'dibayar' => ['Dibayar', 'admin-badge-info'],
        'diproses' => ['Diproses', 'admin-badge-info'],
        'dikirim' => ['Dikirim', 'admin-badge-info'],
        'selesai' => ['Selesai', 'admin-badge-success'],
        'dibatalkan' => ['Dibatalkan', 'admin-badge-danger'],
    ];
@endphp

@section('konten')
    <div class="admin-page-head">
        <div>
            <h1>Dashboard</h1>
            <p>Ringkasan operasional toko Zenvorā hari ini.</p>
        </div>
        <span class="admin-muted" style="font-size: 12px;">{{ now()->translatedFormat('l, d F Y') }}</span>
    </div>

    <section class="admin-grid admin-grid-kpi">
        <article class="kpi-card">
            <span class="kpi-label">Omzet Selesai</span>
            <span class="kpi-value">Rp {{ number_format($omzetSelesai, 0, ',', '.') }}</span>
            <span class="kpi-note">Akumulasi pesanan berstatus selesai</span>
        </article>

        <article class="kpi-card">
            <span class="kpi-label">Perlu Diproses</span>
            <span class="kpi-value">{{ $jumlahPerluProses }}</span>
            <span class="kpi-note">Pesanan menunggu konfirmasi hingga diproses</span>
        </article>

        <article class="kpi-card">
            <span class="kpi-label">Produk Aktif</span>
            <span class="kpi-value">{{ $jumlahProdukAktif }}</span>
            <span class="kpi-note">Total katalog yang tersimpan</span>
        </article>

        <article class="kpi-card">
            <span class="kpi-label">Stok Kritis</span>
            <span class="kpi-value" style="color: {{ $jumlahStokKritis > 0 ? 'var(--danger)' : 'inherit' }};">{{ $jumlahStokKritis }}</span>
            <span class="kpi-note">Produk tersedia dengan stok di bawah 3 unit</span>
        </article>
    </section>

    <section class="admin-two-col">
        <div class="admin-table-wrap">
            <div class="admin-table-head">
                <h2>Pesanan Terbaru</h2>
                <a href="{{ route('admin.pesanan.index') }}" class="admin-page-link" style="font-size: 11px;">Lihat semua</a>
            </div>

            @if ($pesananTerbaru->isEmpty())
                <div class="admin-empty">Belum ada pesanan masuk.</div>
            @else
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Nomor</th>
                            <th>Penerima</th>
                            <th>Status</th>
                            <th style="text-align: right;">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($pesananTerbaru as $pesanan)
                            @php
                                [$teksStatus, $kelasBadge] = $labelStatus[$pesanan->status] ?? [$pesanan->status, 'admin-badge-muted'];
                            @endphp
                            <tr>
                                <td><strong>{{ $pesanan->nomor_pesanan }}</strong></td>
                                <td>{{ $pesanan->nama_penerima }}</td>
                                <td><span class="admin-badge {{ $kelasBadge }}">{{ $teksStatus }}</span></td>
                                <td style="text-align: right;"><strong>Rp {{ number_format($pesanan->total, 0, ',', '.') }}</strong></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </div>

        <div class="admin-card">
            <h2>Stok Menipis</h2>
            <p style="margin-bottom: 14px;">Produk yang perlu segera diisi ulang.</p>

            @if ($produkMenipis->isEmpty())
                <div class="admin-placeholder">Semua stok produk dalam kondisi aman.</div>
            @else
                <table class="admin-table" style="margin: 0 -20px; width: calc(100% + 40px);">
                    <tbody>
                        @foreach ($produkMenipis as $produk)
                            <tr>
                                <td>
                                    <strong>{{ $produk->nama }}</strong><br>
                                    <span style="font-size: 11px;">{{ ucfirst($produk->kategori) }}</span>
                                </td>
                                <td style="text-align: right;">
                                    <span class="admin-badge {{ $produk->stok === 0 ? 'admin-badge-danger' : 'admin-badge-warning' }}">
                                        {{ $produk->stok === 0 ? 'Habis' : $produk->stok.' unit' }}
                                    </span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </div>
    </section>
@endsection
