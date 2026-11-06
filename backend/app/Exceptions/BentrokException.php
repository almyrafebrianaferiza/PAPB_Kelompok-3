<?php

namespace App\Exceptions;

use Exception;

class BentrokException extends Exception
{
    public function __construct(
        string $message = 'Terjadi konflik pada keadaan server',
        protected ?array $data = null,
        int $code = 409
    ) {
        parent::__construct($message, $code);
    }

    public function getData(): ?array
    {
        return $this->data;
    }
}
