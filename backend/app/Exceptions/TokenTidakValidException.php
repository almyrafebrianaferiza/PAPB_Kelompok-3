<?php

namespace App\Exceptions;

use Exception;

class TokenTidakValidException extends Exception
{
    public function __construct(string $message = 'Token tidak valid atau tidak disertakan', int $code = 401)
    {
        parent::__construct($message, $code);
    }
}
