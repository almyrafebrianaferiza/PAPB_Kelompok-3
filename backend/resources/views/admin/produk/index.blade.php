@extends('admin.layouts.app')

@section('konten')
    <div class="admin-page-head">
        <div>
            <h1>Katalog Produk</h1>
            <p>Kelola produk, harga, varian, dan ketersediaan stok.</p>
        </div>
        <a href="{{ route('admin.produk.create') }}" class="admin-btn admin-btn-primary">+ Tambah Produk</a>
    </div>

    @if ($errors->any())
        <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
            {{ $errors->first() }}
        </div>
    @endif

    <form method="GET" action="{{ route('admin.produk.index') }}" class="admin-filter-bar">
        <div class="admin-field" style="flex: 1 1 240px;">
            <label for="cari">Cari Produk</label>
            <input id="cari" type="search" name="cari" value="{{ $cari }}" class="admin-input" placeholder="Nama atau merek...">
        </div>

        <div class="admin-field">
            <label for="kategori">Kategori</label>
            <select id="kategori" name="kategori" class="admin-input admin-select">
                <option value="">Semua kategori</option>
                @foreach ($daftarKategori as $kategori)
                    <option value="{{ $kategori }}" @selected($kategoriTerpilih === $kategori)>{{ ucfirst($kategori) }}</option>
                @endforeach
            </select>
        </div>

        <label class="admin-checkbox" style="padding-bottom: 11px;">
            <input type="checkbox" name="stok" value="kritis" @checked($hanyaKritis)>
            Hanya stok kritis
        </label>

        <button type="submit" class="admin-btn admin-btn-ghost">Terapkan</button>
        @if ($cari !== '' || $kategoriTerpilih || $hanyaKritis)
            <a href="{{ route('admin.produk.index') }}" class="admin-btn admin-btn-ghost">Reset</a>
        @endif
    </form>

    <div class="admin-table-wrap">
        @if ($produk->isEmpty())
            <div class="admin-empty">Tidak ada produk yang cocok dengan filter.</div>
        @else
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Produk</th>
                        <th>Kategori</th>
                        <th style="text-align: right;">Harga</th>
                        <th style="text-align: center;">Stok</th>
                        <th style="text-align: center;">Varian</th>
                        <th>Status</th>
                        <th style="text-align: right;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($produk as $item)
                        <tr>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    @if ($item->gambar_url)
                                        <img src="{{ $item->gambar_url }}" alt="Gambar {{ $item->nama }}" style="width: 48px; height: 48px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border);">
                                    @else
                                        <div style="width: 48px; height: 48px; display: grid; place-items: center; border-radius: 8px; background: var(--surface-elevated); color: var(--text-muted);">
                                            <span aria-hidden="true">—</span>
                                        </div>
                                    @endif
                                    <div>
                                        <strong>{{ $item->nama }}</strong><br>
                                        <span style="font-size: 11px;">{{ $item->merek }}</span>
                                    </div>
                                </div>
                            </td>
                            <td>{{ ucfirst($item->kategori) }}</td>
                            <td style="text-align: right;">Rp {{ number_format($item->harga, 0, ',', '.') }}</td>
                            <td style="text-align: center;">
                                <span class="admin-badge {{ $item->stok === 0 ? 'admin-badge-danger' : ($item->stok < 3 ? 'admin-badge-warning' : 'admin-badge-success') }}">
                                    {{ $item->stok === 0 ? 'Habis' : $item->stok.' unit' }}
                                </span>
                            </td>
                            <td style="text-align: center;">{{ $item->varian_count }}</td>
                            <td>
                                <span class="admin-badge {{ $item->tersedia ? 'admin-badge-success' : 'admin-badge-muted' }}">
                                    {{ $item->tersedia ? 'Tampil' : 'Non-aktif' }}
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div class="admin-table-actions">
                                    <a href="{{ route('admin.produk.edit', $item) }}" class="admin-btn admin-btn-ghost admin-btn-sm">Ubah</a>
                                    <form method="POST" action="{{ route('admin.produk.destroy', $item) }}"
                                          onsubmit="return confirm('Hapus produk {{ $item->nama }}? Produk akan disembunyikan dari katalog.')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="admin-link-danger">Hapus</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @include('admin.partials.pagination', ['paginator' => $produk])
@endsection
