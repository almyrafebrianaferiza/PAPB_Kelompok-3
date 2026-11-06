<?php

namespace App\Enums;

enum StatusPesanan: string
{
    case MenungguPembayaran = 'menunggu_pembayaran';
    case MenungguKonfirmasi = 'menunggu_konfirmasi';
    case Dibayar = 'dibayar';
    case Diproses = 'diproses';
    case Dikirim = 'dikirim';
    case Selesai = 'selesai';
    case Dibatalkan = 'dibatalkan';

    /**
     * Memeriksa apakah perpindahan dari status saat ini ke status tujuan sah.
     */
    public function bolehPindahKe(StatusPesanan $tujuan): bool
    {
        return in_array($tujuan, $this->berikutnya(), true);
    }

    /**
     * Mengembalikan daftar status berikutnya yang sah.
     *
     * @return StatusPesanan[]
     */
    public function berikutnya(): array
    {
        return match ($this) {
            self::MenungguPembayaran => [self::MenungguKonfirmasi, self::Dibatalkan],
            self::MenungguKonfirmasi => [self::Dibayar, self::Dibatalkan],
            self::Dibayar => [self::Diproses],
            self::Diproses => [self::Dikirim],
            self::Dikirim => [self::Selesai],
            self::Selesai, self::Dibatalkan => [],
        };
    }
}
