require 'ffi-rzmq'
require 'msgpack'
require 'socket'
require 'pry-byebug'

host      = "tcp://localhost:5557"
client_id = "test"
ready     = MessagePack.dump(["client_ready", nil, client_id])
hatch     = MessagePack.dump(["hatch_complete", {count: 10}, client_id])
heartbeat = MessagePack.dump(["heartbeat", {state: "running", current_cpu_usage: 10}, client_id])
quit      = MessagePack.dump(["quit", nil, client_id])

context    = ZMQ::Context.new
socket     = context.socket ZMQ::DEALER

socket.setsockopt(ZMQ::IDENTITY, client_id)
socket.connect(host)

# Ready message (Register slave)
ready_msg = ZMQ::Message.new(ready)
socket.sendmsg(ready_msg)

loop do
  sleep(1)

  # Heartbeat
  heartbeat_msg = ZMQ::Message.new(heartbeat)
  socket.sendmsg(heartbeat_msg)

  # Some mock data
  hatch_msg = ZMQ::Message.new(hatch)
  socket.sendmsg(hatch_msg)

  trap "SIGINT" do
    # Quit message
    quit_msg = ZMQ::Message.new(quit)
    socket.sendmsg(quit_msg)
    exit 0
  end
end
