@extends('admin.layouts.app')

@section('konten')
    <div class="admin-page-head">
        <div>
            <h1>Unit &amp; Serial</h1>
            <p>Pantau status fisik setiap unit berdasarkan nomor seri (IMEI/SN).</p>
        </div>
        <span class="admin-status-pill">
            <span class="admin-status-dot"></span>
            {{ $totalSemua }} unit tercatat
        </span>
    </div>

    @if ($errors->any())
        <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
            {{ $errors->first() }}
        </div>
    @endif

    <form method="GET" action="{{ route('admin.unit.index') }}" class="admin-filter-bar">
        <div class="admin-field" style="flex: 1 1 240px;">
            <label for="cari">Cari Nomor Seri</label>
            <input id="cari" type="search" name="cari" value="{{ $cari }}" class="admin-input" placeholder="Contoh: ZNV-P01-0001">
        </div>

        <div class="admin-field">
            <label for="status">Status Unit</label>
            <select id="status" name="status" class="admin-input admin-select">
                <option value="">Semua status</option>
                <option value="tersedia" @selected($statusTerpilih === 'tersedia')>Tersedia ({{ $hitungan['tersedia'] ?? 0 }})</option>
                <option value="terjual" @selected($statusTerpilih === 'terjual')>Terjual ({{ $hitungan['terjual'] ?? 0 }})</option>
                <option value="rusak" @selected($statusTerpilih === 'rusak')>Rusak ({{ $hitungan['rusak'] ?? 0 }})</option>
            </select>
        </div>

        <button type="submit" class="admin-btn admin-btn-ghost">Terapkan</button>
        @if ($cari !== '' || $statusTerpilih)
            <a href="{{ route('admin.unit.index') }}" class="admin-btn admin-btn-ghost">Reset</a>
        @endif
    </form>

    <div class="admin-table-wrap">
        @if ($unit->isEmpty())
            <div class="admin-empty">Tidak ada unit yang cocok dengan filter.</div>
        @else
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Nomor Seri</th>
                        <th>Produk</th>
                        <th>Status</th>
                        <th>Pesanan</th>
                        <th style="text-align: right;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($unit as $item)
                        <tr>
                            <td><span class="admin-unit-serial">{{ $item->nomor_seri }}</span></td>
                            <td>
                                <strong>{{ $item->produk?->nama }}</strong><br>
                                <span style="font-size: 11px;">{{ $item->produk?->merek }}</span>
                            </td>
                            <td>
                                <span class="admin-badge {{ $item->status === 'tersedia' ? 'admin-badge-success' : ($item->status === 'rusak' ? 'admin-badge-danger' : 'admin-badge-info') }}">
                                    {{ ucfirst($item->status) }}
                                </span>
                            </td>
                            <td>
                                @if ($item->detailPesanan?->pesanan)
                                    <span class="admin-unit-serial">{{ $item->detailPesanan->pesanan->nomor_pesanan }}</span>
                                @else
                                    <span class="admin-muted" style="font-size: 11px;">—</span>
                                @endif
                            </td>
                            <td style="text-align: right;">
                                @if ($item->status === 'terjual')
                                    <span class="admin-muted" style="font-size: 11px;">Terikat pesanan</span>
                                @else
                                    <form method="POST" action="{{ route('admin.unit.status', $item) }}"
                                          onsubmit="return confirm('Ubah status unit {{ $item->nomor_seri }}?')">
                                        @csrf
                                        <input type="hidden" name="status" value="{{ $item->status === 'tersedia' ? 'rusak' : 'tersedia' }}">
                                        <button type="submit" class="admin-btn admin-btn-sm {{ $item->status === 'tersedia' ? 'admin-btn-danger' : 'admin-btn-ghost' }}">
                                            {{ $item->status === 'tersedia' ? 'Tandai Rusak' : 'Kembalikan Tersedia' }}
                                        </button>
                                    </form>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @include('admin.partials.pagination', ['paginator' => $unit])
@endsection
