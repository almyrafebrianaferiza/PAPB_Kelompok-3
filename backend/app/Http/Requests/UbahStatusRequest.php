<?php

namespace App\Http\Requests;

use App\Support\Respons;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class UbahStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => 'required|string|in:menunggu_pembayaran,menunggu_konfirmasi,dibayar,diproses,dikirim,selesai,dibatalkan',
        ];
    }

    public function messages(): array
    {
        return [
            'status.required' => 'Status pesanan wajib diisi',
            'status.in' => 'Status harus salah satu dari: menunggu_pembayaran, menunggu_konfirmasi, dibayar, diproses, dikirim, selesai, dibatalkan',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            Respons::gagal('Status tidak valid', 422, $validator->errors()->toArray())
        );
    }
}
