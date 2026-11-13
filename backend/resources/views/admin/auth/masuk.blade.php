<!DOCTYPE html>
<html lang="id">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>Masuk Admin — Zenvorā</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
    </head>
    <body>
        <main class="admin-login">
            <section class="admin-login-card">
                <div class="admin-login-brand">
                    <span class="admin-brand-mark">Z</span>
                    <h1>Masuk Panel Penjual</h1>
                    <p>Kelola pesanan, katalog, dan stok Zenvorā</p>
                </div>

                @if (session('status'))
                    <div class="admin-alert admin-alert-success">{{ session('status') }}</div>
                @endif

                @if ($errors->any())
                    <div class="admin-alert" style="background: rgba(229, 72, 77, 0.12); border-color: rgba(229, 72, 77, 0.35); color: #ff8d90;">
                        {{ $errors->first() }}
                    </div>
                @endif

                <form method="POST" action="{{ route('admin.masuk.proses') }}">
                    @csrf

                    <div class="admin-field">
                        <label for="email">Email Admin</label>
                        <input
                            id="email"
                            type="email"
                            name="email"
                            value="{{ old('email') }}"
                            class="admin-input @error('email') is-invalid @enderror"
                            placeholder="admin@zenvora.test"
                            autocomplete="username"
                            autofocus
                            required
                        >
                    </div>

                    <div class="admin-field">
                        <label for="password">Kata Sandi</label>
                        <input
                            id="password"
                            type="password"
                            name="password"
                            class="admin-input @error('password') is-invalid @enderror"
                            placeholder="••••••••"
                            autocomplete="current-password"
                            required
                        >
                    </div>

                    <button type="submit" class="admin-btn admin-btn-primary admin-btn-block">Masuk ke Panel</button>
                </form>

                @if (config('app.debug'))
                    <p class="admin-login-hint">
                        Mode pengembangan aktif. Kredensial awal:
                        <code>{{ config('admin.email') }}</code> /
                        <code>{{ config('admin.password') }}</code>
                    </p>
                @endif
            </section>
        </main>
    </body>
</html>
