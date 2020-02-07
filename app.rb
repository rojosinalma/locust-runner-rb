require 'ffi-rzmq'
require 'msgpack'
require 'socket'
require 'pry-byebug'

host      = "tcp://localhost:5557"
client_id = "test"
ready = MessagePack.dump(["client_ready", nil, client_id])
hatch = MessagePack.dump(["hatch_complete", {count: 10}, client_id])

context    = ZMQ::Context.new
socket     = context.socket ZMQ::DEALER

socket.setsockopt(ZMQ::IDENTITY, client_id)
socket.connect(host)

ready_msg = ZMQ::Message.new(ready)
socket.sendmsg(ready_msg)

loop do
  sleep(1)
  hatch_msg = ZMQ::Message.new(hatch)
  socket.sendmsg(hatch_msg)
  trap "SIGINT" do
    exit 0
  end
end
