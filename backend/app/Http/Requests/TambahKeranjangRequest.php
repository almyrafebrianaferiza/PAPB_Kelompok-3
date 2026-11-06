<?php

namespace App\Http\Requests;

use App\Support\Respons;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class TambahKeranjangRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'produk_id' => 'required|integer|exists:produk,id',
            'jumlah' => 'required|integer|min:1',
        ];
    }

    public function messages(): array
    {
        return [
            'produk_id.required' => 'Produk tidak ditemukan',
            'produk_id.exists' => 'Produk tidak ditemukan',
            'jumlah.required' => 'Jumlah barang wajib diisi',
            'jumlah.integer' => 'Jumlah barang harus berupa angka',
            'jumlah.min' => 'Jumlah harus lebih besar dari nol',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            Respons::gagal('Data yang dikirim tidak lengkap', 422, $validator->errors()->toArray())
        );
    }
}
