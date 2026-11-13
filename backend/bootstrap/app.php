<?php

use App\Exceptions\BentrokException;
use App\Exceptions\TokenTidakValidException;
use App\Http\Middleware\PastikanAdmin;
use App\Support\Respons;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'admin' => PastikanAdmin::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $keJson = fn (Request $request): bool => $request->is('api/*') || $request->expectsJson();

        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $keJson($request),
        );

        // 404 — endpoint tidak ada (api-contract 1.2)
        $exceptions->render(function (NotFoundHttpException $e, Request $request) use ($keJson) {
            if ($keJson($request)) {
                return Respons::gagal('Endpoint tidak ditemukan', 404);
            }
        });

        // 405 — metode tidak diizinkan untuk endpoint
        $exceptions->render(function (MethodNotAllowedHttpException $e, Request $request) use ($keJson) {
            if ($keJson($request)) {
                return Respons::gagal('Metode HTTP tidak diizinkan untuk endpoint ini', 405);
            }
        });

        // 422 — jaring pengaman validasi yang lolos dari FormRequest
        $exceptions->render(function (ValidationException $e, Request $request) use ($keJson) {
            if ($keJson($request)) {
                return Respons::gagal($e->getMessage(), 422, $e->errors());
            }
        });

        // 409 — bentrok bisnis (stok/tidak tersedia/Transisi status)
        $exceptions->render(function (BentrokException $e) {
            return Respons::gagal($e->getMessage(), 409, null, $e->getData());
        });

        // 401 — token tidak valid
        $exceptions->render(function (TokenTidakValidException $e) {
            return Respons::gagal($e->getMessage(), 401);
        });

        // 500 — galat tak terduga; pesan umum tanpa jejak (uji C13)
        $exceptions->render(function (Throwable $e, Request $request) use ($keJson) {
            if ($keJson($request)) {
                return Respons::gagal('Terjadi kesalahan pada server', 500);
            }
        });
    })->create();
