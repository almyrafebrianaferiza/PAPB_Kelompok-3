<!DOCTYPE html>
<html lang="id">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ ($judulHalaman ?? 'Panel Admin').' — Zenvorā Admin' }}</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
    </head>
    <body>
        <div class="admin-shell">
            @include('admin.layouts.sidebar')

            <div class="admin-main">
                @include('admin.layouts.topbar')

                <main class="admin-content">
                    @if (session('status'))
                        <div class="admin-alert admin-alert-success">{{ session('status') }}</div>
                    @endif

                    @yield('konten')
                </main>
            </div>
        </div>

        @stack('skrip')
    </body>
</html>
