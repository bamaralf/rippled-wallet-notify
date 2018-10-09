require 'rubygems'
require 'websocket-client-simple'
require "bunny"

def send_to_queue(queued_message)
  connection = Bunny.new ENV['RABBITMQ_URL']
  connection.start # Start a communication session with the amqp server
  channel = connection.create_channel # Declare a channel
  queue = channel.queue(ENV['QUEUE']) # Declare a queue
  exchange = channel.exchange("") # Declare a default direct exchange which is bound to all queues 
  exchange.publish(queued_message, :key => queue.name) # Publish a message to the exchange which then gets routed to the queue
  connection.close # Finally, close the connection
end

ws = WebSocket::Client::Simple.connect ENV['WS_ADDR']
  ws.on :open do
  ws.send ENV['ACCOUNT_CMD']
  end

  ws.on :message do |msg|
     output = eval(msg.data.to_s) # Get msg.data.to_s String and convert it to a Hash.
     unless output.nil? or output[:id]
         message = { channel_key: ENV['CHANNEL'], txid: output[:transaction][:hash] }
        send_to_queue(message.to_s)
      end
  end

  ws.on :close do |e|
    p e
    exit 1
  end
  
  ws.on :error do |e|
    p e
  end
  
  loop do
    ws.send STDIN.gets.strip
  end
