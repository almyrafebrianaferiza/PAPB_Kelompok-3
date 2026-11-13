@php
    $peta = [
        'menunggu_pembayaran' => ['Menunggu Pembayaran', 'admin-badge-warning'],
        'menunggu_konfirmasi' => ['Menunggu Konfirmasi', 'admin-badge-warning'],
        'dibayar' => ['Dibayar', 'admin-badge-info'],
        'diproses' => ['Diproses', 'admin-badge-info'],
        'dikirim' => ['Dikirim', 'admin-badge-info'],
        'selesai' => ['Selesai', 'admin-badge-success'],
        'dibatalkan' => ['Dibatalkan', 'admin-badge-danger'],
    ];

    [$teks, $kelas] = $peta[$status] ?? [$status, 'admin-badge-muted'];
@endphp

<span class="admin-badge {{ $kelas }}">{{ $teks }}</span>
