@extends('admin.layouts.app')

@php
    $labelStatus = [
        'menunggu_pembayaran' => 'Menunggu Pembayaran',
        'menunggu_konfirmasi' => 'Menunggu Konfirmasi',
        'dibayar' => 'Dibayar',
        'diproses' => 'Diproses',
        'dikirim' => 'Dikirim',
        'selesai' => 'Selesai',
        'dibatalkan' => 'Dibatalkan',
    ];
@endphp

@section('konten')
    <div class="admin-page-head">
        <div>
            <h1>Pesanan Masuk</h1>
            <p>Verifikasi pembayaran, proses pengemasan, dan input resi pengiriman.</p>
        </div>
        <span class="admin-status-pill">
            <span class="admin-status-dot"></span>
            {{ $totalSemua }} pesanan tercatat
        </span>
    </div>

    @if ($errors->any())
        <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
            {{ $errors->first() }}
        </div>
    @endif

    <nav class="admin-tabs" aria-label="Filter status pesanan">
        <a href="{{ route('admin.pesanan.index') }}"
           class="admin-tab {{ $statusTerpilih === null ? 'is-active' : '' }}">
            Semua <span>{{ $totalSemua }}</span>
        </a>

        @foreach ($daftarStatus as $status)
            <a href="{{ route('admin.pesanan.index', ['status' => $status->value]) }}"
               class="admin-tab {{ $statusTerpilih === $status->value ? 'is-active' : '' }}">
                {{ $labelStatus[$status->value] ?? $status->value }}
                <span>{{ $hitunganStatus[$status->value] ?? 0 }}</span>
            </a>
        @endforeach
    </nav>

    <div class="admin-table-wrap">
        @if ($pesanan->isEmpty())
            <div class="admin-empty">Tidak ada pesanan pada filter ini.</div>
        @else
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Nomor</th>
                        <th>Tanggal</th>
                        <th>Penerima</th>
                        <th>Kurir</th>
                        <th style="text-align: right;">Total</th>
                        <th>Status</th>
                        <th style="text-align: right;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($pesanan as $item)
                        <tr>
                            <td><strong>{{ $item->nomor_pesanan }}</strong></td>
                            <td>{{ $item->created_at->format('d M Y, H:i') }}</td>
                            <td>
                                <strong>{{ $item->nama_penerima }}</strong><br>
                                <span style="font-size: 11px;">{{ $item->pelanggan?->nama }}</span>
                            </td>
                            <td>{{ $item->kurir?->nama }}</td>
                            <td style="text-align: right;"><strong>Rp {{ number_format($item->total, 0, ',', '.') }}</strong></td>
                            <td>@include('admin.partials.badge-status', ['status' => $item->status])</td>
                            <td style="text-align: right;">
                                <a href="{{ route('admin.pesanan.show', $item) }}" class="admin-btn admin-btn-ghost admin-btn-sm">Detail</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @include('admin.partials.pagination', ['paginator' => $pesanan])
@endsection
