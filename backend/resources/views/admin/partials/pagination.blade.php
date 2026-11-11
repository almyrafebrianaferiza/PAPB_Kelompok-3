@if ($paginator->hasPages())
    <nav class="admin-pagination" aria-label="Navigasi halaman">
        @if ($paginator->onFirstPage())
            <span class="admin-page-link is-disabled">‹ Sebelumnya</span>
        @else
            <a href="{{ $paginator->previousPageUrl() }}" class="admin-page-link">‹ Sebelumnya</a>
        @endif

        <span class="admin-page-info">Halaman {{ $paginator->currentPage() }} dari {{ $paginator->lastPage() }}</span>

        @if ($paginator->hasMorePages())
            <a href="{{ $paginator->nextPageUrl() }}" class="admin-page-link">Berikutnya ›</a>
        @else
            <span class="admin-page-link is-disabled">Berikutnya ›</span>
        @endif
    </nav>
@endif
