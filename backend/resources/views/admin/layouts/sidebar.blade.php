<aside class="admin-sidebar">
    <div class="admin-brand">
        <span class="admin-brand-mark">Z</span>
        <span class="admin-brand-text">
            <strong>Zenvorā</strong>
            <span>Seller Panel</span>
        </span>
    </div>

    <nav class="admin-nav" aria-label="Navigasi admin">
        <span class="admin-nav-label">Menu Utama</span>

        <a href="{{ route('admin.dashboard') }}"
           class="admin-nav-item {{ request()->routeIs('admin.dashboard') ? 'is-active' : '' }}">
            <svg class="admin-nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <rect x="3" y="3" width="7" height="7" rx="1.5"></rect>
                <rect x="14" y="3" width="7" height="7" rx="1.5"></rect>
                <rect x="3" y="14" width="7" height="7" rx="1.5"></rect>
                <rect x="14" y="14" width="7" height="7" rx="1.5"></rect>
            </svg>
            Dashboard
        </a>

        <a href="{{ route('admin.pesanan.index') }}"
           class="admin-nav-item {{ request()->routeIs('admin.pesanan.*') ? 'is-active' : '' }}">
            <svg class="admin-nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                <path d="M3 6h18"></path>
                <path d="M16 10a4 4 0 0 1-8 0"></path>
            </svg>
            Pesanan Masuk
        </a>

        <a href="{{ route('admin.produk.index') }}"
           class="admin-nav-item {{ request()->routeIs('admin.produk.*') ? 'is-active' : '' }}">
            <svg class="admin-nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                <path d="m3.3 7 8.7 5 8.7-5"></path>
                <path d="M12 22V12"></path>
            </svg>
            Katalog Produk
        </a>

        <a href="{{ route('admin.unit.index') }}"
           class="admin-nav-item {{ request()->routeIs('admin.unit.*') ? 'is-active' : '' }}">
            <svg class="admin-nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <rect x="3" y="3" width="18" height="18" rx="2"></rect>
                <path d="M7 7h4v4H7z"></path>
                <path d="M7 17h2"></path>
                <path d="M15 17h2"></path>
                <path d="M15 13h2"></path>
            </svg>
            Unit &amp; Serial
        </a>
    </nav>

    <div class="admin-sidebar-footer">
        <p>Masuk sebagai</p>
        <strong>{{ session('admin_email', config('admin.email')) }}</strong>
        <span>Administrator Toko</span>
    </div>
</aside>
