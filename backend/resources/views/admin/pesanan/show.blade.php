@extends('admin.layouts.app')

@php
    $labelAksi = [
        'menunggu_konfirmasi' => 'Verifikasi Menunggu Konfirmasi',
        'dibayar' => 'Konfirmasi Pembayaran',
        'diproses' => 'Mulai Kemas',
        'selesai' => 'Tandai Selesai',
        'dibatalkan' => 'Batalkan Pesanan',
    ];
@endphp

@section('konten')
    <div class="admin-page-head">
        <div>
            <p class="admin-crumb"><a href="{{ route('admin.pesanan.index') }}">Pesanan Masuk</a> / Rincian</p>
            <h1>{{ $pesanan->nomor_pesanan }}</h1>
            <p>Dibuat {{ $pesanan->created_at->format('d F Y, H:i') }} WIB</p>
        </div>
        <div>@include('admin.partials.badge-status', ['status' => $pesanan->status])</div>
    </div>

    @if ($errors->any())
        <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
            {{ $errors->first() }}
        </div>
    @endif

    <section class="admin-detail-grid">
        <div class="admin-stack">
            <div class="admin-table-wrap">
                <div class="admin-table-head">
                    <h2>Item Pesanan</h2>
                    <span class="admin-muted" style="font-size: 11.5px;">{{ $pesanan->detail->sum('jumlah') }} unit</span>
                </div>

                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Produk</th>
                            <th style="text-align: center;">Qty</th>
                            <th style="text-align: right;">Harga</th>
                            <th>Nomor Seri</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($pesanan->detail as $detail)
                            <tr>
                                <td><strong>{{ $detail->nama_produk }}</strong></td>
                                <td style="text-align: center;">{{ $detail->jumlah }}</td>
                                <td style="text-align: right;">Rp {{ number_format($detail->harga_satuan, 0, ',', '.') }}</td>
                                <td>
                                    @forelse ($detail->unit as $unit)
                                        <span class="admin-chip">{{ $unit->nomor_seri }}</span>
                                    @empty
                                        <span class="admin-muted" style="font-size: 11px;">Belum dialokasikan</span>
                                    @endforelse
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <div class="admin-card">
                <h2>Informasi Pengiriman</h2>
                <dl class="admin-detail-list">
                    <div>
                        <dt>Nama Penerima</dt>
                        <dd>{{ $pesanan->nama_penerima }}</dd>
                    </div>
                    <div>
                        <dt>Alamat</dt>
                        <dd>{{ $pesanan->alamat_penerima }}</dd>
                    </div>
                    <div>
                        <dt>Kurir</dt>
                        <dd>{{ $pesanan->kurir?->nama }} ({{ $pesanan->kurir?->wilayah }})</dd>
                    </div>
                    <div>
                        <dt>Metode Pembayaran</dt>
                        <dd>{{ $pesanan->metodePembayaran?->nama }}</dd>
                    </div>
                    <div>
                        <dt>Berat Tertagih</dt>
                        <dd>{{ $pesanan->berat_kg_tertagih }} kg ({{ $pesanan->total_berat_gram }} gram)</dd>
                    </div>
                    <div>
                        <dt>Nomor Resi</dt>
                        <dd>{{ $pesanan->nomor_resi ?? 'Belum diinput' }}</dd>
                    </div>
                </dl>
            </div>
        </div>

        <div class="admin-stack">
            <div class="admin-card">
                <h2>Ringkasan Biaya</h2>
                <dl class="admin-detail-list">
                    <div>
                        <dt>Subtotal</dt>
                        <dd>Rp {{ number_format($pesanan->subtotal, 0, ',', '.') }}</dd>
                    </div>
                    <div>
                        <dt>Ongkir</dt>
                        <dd>Rp {{ number_format($pesanan->ongkir, 0, ',', '.') }}</dd>
                    </div>
                    <div class="is-total">
                        <dt>Total</dt>
                        <dd>Rp {{ number_format($pesanan->total, 0, ',', '.') }}</dd>
                    </div>
                </dl>
            </div>

            <div class="admin-card">
                <h2>Aksi Fulfillment</h2>
                <p style="margin-bottom: 14px;">Status mengikuti alur pesanan yang sah.</p>

                @if (empty($statusBerikutnya))
                    <div class="admin-placeholder">Pesanan ini sudah final dan tidak dapat diubah lagi.</div>
                @else
                    <div class="admin-action-stack">
                        @foreach ($statusBerikutnya as $status)
                            @if ($status->value === 'dikirim')
                                <form method="POST" action="{{ route('admin.pesanan.resi', $pesanan) }}" class="admin-inline-form">
                                    @csrf
                                    <div class="admin-field" style="margin-bottom: 0;">
                                        <label for="nomor_resi">Nomor Resi {{ $pesanan->kurir?->nama }}</label>
                                        <input
                                            id="nomor_resi"
                                            type="text"
                                            name="nomor_resi"
                                            value="{{ old('nomor_resi', $pesanan->nomor_resi) }}"
                                            class="admin-input @error('nomor_resi') is-invalid @enderror"
                                            placeholder="Contoh: JNE1234567890"
                                            required
                                        >
                                    </div>
                                    <button type="submit" class="admin-btn admin-btn-primary admin-btn-block">Simpan Resi &amp; Kirim</button>
                                </form>
                            @else
                                <form method="POST" action="{{ route('admin.pesanan.status', $pesanan) }}"
                                      @if ($status->value === 'dibatalkan') onsubmit="return confirm('Batalkan pesanan ini? Unit akan otomatis dikembalikan ke stok tersedia.')" @endif>
                                    @csrf
                                    <input type="hidden" name="status" value="{{ $status->value }}">
                                    <button type="submit" class="admin-btn admin-btn-block {{ $status->value === 'dibatalkan' ? 'admin-btn-danger' : 'admin-btn-primary' }}">
                                        {{ $labelAksi[$status->value] ?? $status->value }}
                                    </button>
                                </form>
                            @endif
                        @endforeach
                    </div>

                    @if ($pesanan->status === 'dikirim')
                        <form method="POST" action="{{ route('admin.pesanan.resi', $pesanan) }}" class="admin-inline-form" style="margin-top: 14px;">
                            @csrf
                            <div class="admin-field" style="margin-bottom: 0;">
                                <label for="nomor_resi">Perbarui Nomor Resi</label>
                                <input id="nomor_resi" type="text" name="nomor_resi" value="{{ $pesanan->nomor_resi }}" class="admin-input" required>
                            </div>
                            <button type="submit" class="admin-btn admin-btn-ghost admin-btn-block">Perbarui Resi</button>
                        </form>
                    @endif
                @endif
            </div>
        </div>
    </section>
@endsection
