<?php

namespace SimpleProject\Tests;

use PHPUnit\Framework\TestCase;

class VtigerTest extends TestCase
{
    public function testUser()
    {
        $simpleObject = new \SimpleProject\SimpleClass();
        $this->assertEquals('simple', $simpleObject->simpleMethod(), 'Simple method should return "simple"');
    }
}
