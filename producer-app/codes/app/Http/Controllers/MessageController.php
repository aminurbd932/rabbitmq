<?php

namespace App\Http\Controllers;

use App\Services\RabbitMQService;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function sendMessage()
    {
        $rabbitmqService = new RabbitMQService();
       $rabbitmqService->sendMessage('2dbCM', 'Hello RabbitMQ!');
        return response()->json(['message' => 'Message sent successfully']);
    }
}
