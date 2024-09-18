<?php

namespace App\Console\Commands;

use App\Services\RabbitMQService;
use Illuminate\Console\Command;

class ConsumeMessages extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'consume:messages';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Consume messages from RabbitMQ';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $rabbitmqService = new RabbitMQService();
        $rabbitmqService->consumeMessages('2dbCM', function ($message) {
            // Process the message here
            $this->info("Received message: {$message->getBody()}");
        });
    }
}
