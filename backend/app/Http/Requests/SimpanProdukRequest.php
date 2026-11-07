<?php

namespace App\Http\Requests;

use App\Support\Respons;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Rule;

class SimpanProdukRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama' => 'required|string|max:150',
            'merek' => 'required|string|max:60',
            'harga' => 'required|integer|min:0',
            'kategori' => ['required', 'string', Rule::in(config('zenvora.kategori'))],
            'stok' => 'required|integer|min:0',
            'tersedia' => 'sometimes|boolean',
            'deskripsi' => 'nullable|string',
            'berat_gram' => 'required|integer|min:1',
            'garansi_bulan' => 'required|integer|min:0',
        ];
    }

    public function messages(): array
    {
        return [
            'nama.required' => 'Nama produk wajib diisi',
            'nama.max' => 'Nama produk maksimal 150 karakter',
            'merek.required' => 'Merek produk wajib diisi',
            'merek.max' => 'Merek produk maksimal 60 karakter',
            'harga.required' => 'Harga produk wajib diisi',
            'harga.integer' => 'Harga produk harus berupa bilangan bulat',
            'harga.min' => 'Harga produk tidak boleh negatif',
            'kategori.required' => 'Kategori produk wajib diisi',
            'kategori.in' => 'Kategori harus salah satu dari: gadget, laptop, tv, monitor, tablet',
            'stok.required' => 'Stok produk wajib diisi',
            'stok.integer' => 'Stok produk harus berupa bilangan bulat',
            'stok.min' => 'Stok produk minimal 0 unit',
            'berat_gram.required' => 'Berat produk wajib diisi',
            'berat_gram.min' => 'Berat produk minimal 1 gram',
            'garansi_bulan.required' => 'Masa garansi wajib diisi',
            'garansi_bulan.min' => 'Masa garansi minimal 0 bulan',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            Respons::gagal('Data yang dikirim tidak lengkap', 422, $validator->errors()->toArray())
        );
    }
}
