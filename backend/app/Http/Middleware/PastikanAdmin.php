<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class PastikanAdmin
{
    /**
     * Memastikan hanya sesi admin web yang dapat mengakses panel.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->session()->get('admin_terautentikasi', false)) {
            return redirect()->guest(route('admin.masuk'));
        }

        return $next($request);
    }
}
