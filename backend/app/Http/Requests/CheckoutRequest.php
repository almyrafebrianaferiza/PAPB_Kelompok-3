<?php

namespace App\Http\Requests;

use App\Support\Respons;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class CheckoutRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'kurir_id' => 'required|integer|exists:kurir,id',
            'metode_pembayaran_id' => 'required|integer|exists:metode_pembayaran,id',
            'nama_penerima' => 'required|string|max:100',
            'alamat_penerima' => 'required|string|min:10|max:500',
        ];
    }

    public function messages(): array
    {
        return [
            'kurir_id.required' => 'Kurir pengiriman wajib dipilih',
            'kurir_id.exists' => 'Kurir pengiriman tidak valid',
            'metode_pembayaran_id.required' => 'Metode pembayaran wajib dipilih',
            'metode_pembayaran_id.exists' => 'Metode pembayaran tidak valid',
            'nama_penerima.required' => 'Nama penerima wajib diisi',
            'nama_penerima.max' => 'Nama penerima maksimal 100 karakter',
            'alamat_penerima.required' => 'Alamat penerima wajib diisi',
            'alamat_penerima.min' => 'Alamat penerima minimal 10 karakter',
            'alamat_penerima.max' => 'Alamat penerima maksimal 500 karakter',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            Respons::gagal('Data yang dikirim tidak lengkap', 422, $validator->errors()->toArray())
        );
    }
}
