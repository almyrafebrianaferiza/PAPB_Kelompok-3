@extends('admin.layouts.app')

@php
    $varianAwal = old('varian', $produk->varian->map(fn ($varian) => [
        'id' => $varian->id,
        'nama_varian' => $varian->nama_varian,
        'harga' => $varian->harga,
        'stok' => $varian->stok,
        'berat_gram' => $varian->berat_gram,
        'sku' => $varian->sku,
    ])->all());

    if (! is_array($varianAwal)) {
        $varianAwal = [];
    }
@endphp

@section('konten')
    <div class="admin-page-head">
        <div>
            <p class="admin-crumb"><a href="{{ route('admin.produk.index') }}">Katalog Produk</a> / {{ $mode === 'create' ? 'Tambah' : 'Ubah' }}</p>
            <h1>{{ $mode === 'create' ? 'Tambah Produk' : 'Ubah Produk' }}</h1>
            <p>{{ $mode === 'create' ? 'Lengkapi data produk elektronik baru.' : 'Perbarui data produk, varian, dan stok fisik.' }}</p>
        </div>
    </div>

    @if ($errors->any())
        <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
            {{ $errors->first() }}
        </div>
    @endif

    <form method="POST"
          action="{{ $mode === 'create' ? route('admin.produk.store') : route('admin.produk.update', $produk) }}">
        @csrf
        @if ($mode === 'edit')
            @method('PUT')
        @endif

        <section class="admin-stack">
            <div class="admin-form-card">
                <h2>Informasi Produk</h2>
                <p>Data utama yang tampil pada katalog mobile.</p>

                <div class="admin-form-grid">
                    <div class="admin-field admin-field-full">
                        <label for="nama">Nama Produk</label>
                        <input id="nama" type="text" name="nama" value="{{ old('nama', $produk->nama) }}" class="admin-input" required maxlength="150">
                    </div>

                    <div class="admin-field">
                        <label for="merek">Merek</label>
                        <input id="merek" type="text" name="merek" value="{{ old('merek', $produk->merek) }}" class="admin-input" required maxlength="60">
                    </div>

                    <div class="admin-field">
                        <label for="kategori">Kategori</label>
                        <select id="kategori" name="kategori" class="admin-input admin-select" required>
                            @foreach ($daftarKategori as $kategori)
                                <option value="{{ $kategori }}" @selected(old('kategori', $produk->kategori) === $kategori)>{{ ucfirst($kategori) }}</option>
                            @endforeach
                        </select>
                    </div>

                    <div class="admin-field">
                        <label for="harga">Harga Dasar (Rp)</label>
                        <input id="harga" type="number" name="harga" value="{{ old('harga', $produk->harga) }}" class="admin-input" min="0" required>
                    </div>

                    <div class="admin-field">
                        <label for="stok">Stok Fisik (unit)</label>
                        <input id="stok" type="number" name="stok" value="{{ old('stok', $produk->stok ?? 0) }}" class="admin-input" min="0" required>
                        <span style="font-size: 10.5px; color: var(--text-muted);">Diabaikan bila varian diisi; stok mengikuti total varian.</span>
                    </div>

                    <div class="admin-field">
                        <label for="berat_gram">Berat (gram)</label>
                        <input id="berat_gram" type="number" name="berat_gram" value="{{ old('berat_gram', $produk->berat_gram) }}" class="admin-input" min="1" required>
                    </div>

                    <div class="admin-field">
                        <label for="garansi_bulan">Garansi (bulan)</label>
                        <input id="garansi_bulan" type="number" name="garansi_bulan" value="{{ old('garansi_bulan', $produk->garansi_bulan) }}" class="admin-input" min="0" required>
                    </div>

                    <div class="admin-field admin-field-full">
                        <label for="deskripsi">Deskripsi</label>
                        <textarea id="deskripsi" name="deskripsi" class="admin-input admin-textarea" maxlength="2000">{{ old('deskripsi', $produk->deskripsi) }}</textarea>
                    </div>

                    <div class="admin-field admin-field-full">
                        <label class="admin-checkbox">
                            <input type="checkbox" name="tersedia" value="1" @checked(old('tersedia', $produk->exists ? $produk->tersedia : true))>
                            Tampilkan produk pada katalog mobile
                        </label>
                    </div>
                </div>
            </div>

            <div class="admin-form-card">
                <h2>Varian Produk</h2>
                <p>Opsional. Isi kombinasi RAM, penyimpanan, atau warna dengan harga dan stok masing-masing.</p>

                <div id="daftar-varian" class="admin-variant-list">
                    @foreach ($varianAwal as $indeks => $varian)
                        <div class="admin-variant-row">
                            <input type="hidden" name="varian[{{ $indeks }}][id]" value="{{ $varian['id'] ?? '' }}">

                            <div class="admin-field">
                                <label>Nama Varian</label>
                                <input type="text" name="varian[{{ $indeks }}][nama_varian]" value="{{ $varian['nama_varian'] ?? '' }}" class="admin-input" maxlength="100" placeholder="8GB / 256GB - Iceblue">
                            </div>

                            <div class="admin-field">
                                <label>Harga (Rp)</label>
                                <input type="number" name="varian[{{ $indeks }}][harga]" value="{{ $varian['harga'] ?? 0 }}" class="admin-input" min="0">
                            </div>

                            <div class="admin-field">
                                <label>Stok</label>
                                <input type="number" name="varian[{{ $indeks }}][stok]" value="{{ $varian['stok'] ?? 0 }}" class="admin-input" min="0">
                            </div>

                            <div class="admin-field">
                                <label>Berat</label>
                                <input type="number" name="varian[{{ $indeks }}][berat_gram]" value="{{ $varian['berat_gram'] ?? 0 }}" class="admin-input" min="0">
                            </div>

                            <div class="admin-field">
                                <label>SKU</label>
                                <input type="text" name="varian[{{ $indeks }}][sku]" value="{{ $varian['sku'] ?? '' }}" class="admin-input" maxlength="50">
                            </div>

                            <button type="button" class="admin-icon-btn" data-hapus title="Hapus varian">×</button>
                        </div>
                    @endforeach
                </div>

                <div style="margin-top: 12px;">
                    <button type="button" id="tambah-varian" class="admin-btn admin-btn-ghost admin-btn-sm">+ Tambah Varian</button>
                </div>
            </div>

            <div class="admin-form-actions">
                <a href="{{ route('admin.produk.index') }}" class="admin-btn admin-btn-ghost">Batal</a>
                <button type="submit" class="admin-btn admin-btn-primary">
                    {{ $mode === 'create' ? 'Simpan Produk' : 'Simpan Perubahan' }}
                </button>
            </div>
        </section>
    </form>

    <template id="tpl-varian">
        <div class="admin-variant-row">
            <input type="hidden" name="varian[__i__][id]" value="">

            <div class="admin-field">
                <label>Nama Varian</label>
                <input type="text" name="varian[__i__][nama_varian]" class="admin-input" maxlength="100" placeholder="8GB / 256GB - Iceblue">
            </div>

            <div class="admin-field">
                <label>Harga (Rp)</label>
                <input type="number" name="varian[__i__][harga]" value="0" class="admin-input" min="0">
            </div>

            <div class="admin-field">
                <label>Stok</label>
                <input type="number" name="varian[__i__][stok]" value="0" class="admin-input" min="0">
            </div>

            <div class="admin-field">
                <label>Berat</label>
                <input type="number" name="varian[__i__][berat_gram]" value="0" class="admin-input" min="0">
            </div>

            <div class="admin-field">
                <label>SKU</label>
                <input type="text" name="varian[__i__][sku]" class="admin-input" maxlength="50">
            </div>

            <button type="button" class="admin-icon-btn" data-hapus title="Hapus varian">×</button>
        </div>
    </template>
@endsection

@push('skrip')
    <script>
        (function () {
            const daftar = document.getElementById('daftar-varian');
            const templat = document.getElementById('tpl-varian');
            const tambah = document.getElementById('tambah-varian');
            let urutan = {{ count($varianAwal) }};

            tambah.addEventListener('click', function () {
                const baris = templat.content.cloneNode(true);
                baris.querySelectorAll('[name]').forEach(function (input) {
                    input.name = input.name.replace('__i__', urutan);
                });
                daftar.appendChild(baris);
                urutan++;
            });

            daftar.addEventListener('click', function (event) {
                const tombol = event.target.closest('[data-hapus]');
                if (! tombol) {
                    return;
                }
                tombol.closest('.admin-variant-row').remove();
            });
        })();
    </script>
@endpush
