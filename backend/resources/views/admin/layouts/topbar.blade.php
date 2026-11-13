<header class="admin-topbar">
    <div class="admin-breadcrumb">
        <span>Seller Panel</span>
        <span>/</span>
        <strong>{{ $judulHalaman ?? 'Dashboard' }}</strong>
    </div>

    <div class="admin-topbar-actions">
        <span class="admin-status-pill">
            <span class="admin-status-dot"></span>
            Backend Online
        </span>

        <div class="admin-user">
            <span class="admin-user-avatar">A</span>
            <span class="admin-user-meta">
                <strong>{{ config('admin.nama') }}</strong>
                <span>{{ session('admin_email', config('admin.email')) }}</span>
            </span>
        </div>

        <form method="POST" action="{{ route('admin.keluar') }}">
            @csrf
            <button type="submit" class="admin-btn admin-btn-ghost">Keluar</button>
        </form>
    </div>
</header>
