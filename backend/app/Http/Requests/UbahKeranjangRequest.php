<?php

namespace App\Http\Requests;

use App\Support\Respons;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class UbahKeranjangRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'jumlah' => 'required|integer|min:1',
        ];
    }

    public function messages(): array
    {
        return [
            'jumlah.required' => 'Jumlah harus lebih besar dari nol',
            'jumlah.integer' => 'Jumlah barang harus berupa bilangan bulat',
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
