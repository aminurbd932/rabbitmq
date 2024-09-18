<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use PhpAmqpLib\Connection\AMQPStreamConnection;
use PhpAmqpLib\Exception\AMQPException;
use PhpAmqpLib\Exception\AMQPTimeoutException;

class RabbitMQService
{
    private $connection;
    private $channel;

    public function __construct()
    {
        $this->connect();
    }

    public function connect()
    {
        try {
            $this->connection = new AMQPStreamConnection(
                env('RABBITMQ_HOST'),
                env('RABBITMQ_PORT'),
                env('RABBITMQ_USER'),
                env('RABBITMQ_PASSWORD'),
                // env('RABBITMQ_VHOST', '/'),
                // false,                 // Insist on connecting to the broker
                // 'AMQPLAIN',            // Login method
                // null,                  // Login response
                // 'en_US',               // Locale
                // env('RABBITMQ_CONNECTION_TIMEOUT', 60),   // Connection timeout
                // env('RABBITMQ_READ_WRITE_TIMEOUT', 60),   // Read/Write timeout
                // null,                  // Context
            );
            $this->channel = $this->connection->channel();
        } catch (AMQPTimeoutException $e) {
            Log::warning('RabbitMQ timeout: ' . $e->getMessage());
            $this->retryConnection();
        } catch (\Exception $e) {
            Log::error('RabbitMQ error: ' . $e->getMessage());
            // Optional: Handle reconnection if needed
        }
    }

    private function retryConnection()
    {
        // Logic to retry the connection after a timeout
        Log::info('Retrying RabbitMQ connection...');
        sleep(5); // Optional delay before retrying
        $this->connect();
    }

    public function consumeMessages(string $queue, callable $callback)
    {
        try {
            $this->channel->queue_declare($queue, false, true, false, false);
             // Set a consumer tag to identify the consumer
            $this->channel->basic_consume($queue, '', false, true, false, false, $callback);

            while (count($this->channel->callbacks)) {
                $this->channel->wait(); // Add timeout parameter to avoid indefinite wait
            }
        } catch (AMQPTimeoutException $e) {
            Log::warning('RabbitMQ timeout during message consumption: ' . $e->getMessage());
            $this->retryConnection();
        } catch (\Exception $e) {
            Log::error('RabbitMQ error during message consumption2: ' . $e->getMessage());
            $this->retryConnection();
        }
    }

    public function __destruct()
    {
        try {
            $this->channel->close();
            $this->connection->close();
        } catch (\Exception $e) {
            Log::error('RabbitMQ error during connection closure3: ' . $e->getMessage());
        }
    }
}
