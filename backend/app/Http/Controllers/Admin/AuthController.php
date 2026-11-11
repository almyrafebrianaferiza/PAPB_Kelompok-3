<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\View\View;

class AuthController extends Controller
{
    /**
     * Menampilkan formulir masuk admin web.
     */
    public function formulir(Request $request): View|RedirectResponse
    {
        if ($request->session()->get('admin_terautentikasi', false)) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.auth.masuk');
    }

    /**
     * Memproses autentikasi admin web berbasis sesi.
     */
    public function masuk(Request $request): RedirectResponse
    {
        $kredensial = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Email admin wajib diisi.',
            'email.email' => 'Format email admin tidak valid.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        $kunci = 'admin-masuk:'.$request->ip();

        if (RateLimiter::tooManyAttempts($kunci, 5)) {
            $detik = RateLimiter::availableIn($kunci);

            return back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => "Terlalu banyak percobaan. Coba lagi dalam {$detik} detik."]);
        }

        $emailCocok = hash_equals((string) config('admin.email'), (string) $kredensial['email']);
        $sandiCocok = hash_equals((string) config('admin.password'), (string) $kredensial['password']);

        if (! $emailCocok || ! $sandiCocok) {
            RateLimiter::hit($kunci, 60);

            return back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => 'Email atau kata sandi admin tidak cocok.']);
        }

        RateLimiter::clear($kunci);

        $request->session()->regenerate();
        $request->session()->put('admin_terautentikasi', true);
        $request->session()->put('admin_email', $kredensial['email']);

        return redirect()->intended(route('admin.dashboard'));
    }

    /**
     * Mengakhiri sesi admin web.
     */
    public function keluar(Request $request): RedirectResponse
    {
        $request->session()->forget(['admin_terautentikasi', 'admin_email']);
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.masuk')
            ->with('status', 'Anda telah keluar dari panel admin.');
    }
}
