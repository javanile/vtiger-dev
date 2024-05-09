<?php

namespace 7.1.0 - php7.4;
use PHPUnit\Framework\TestCase;

class VtigerTest extends TestCase
{
    public function testUser()
    {
        global $current_user;
        var_dump($current_user);
    }
}
