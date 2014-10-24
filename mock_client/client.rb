if ARGV.length == 0 
  puts 'Missing device ID'
  return
end

require 'em-websocket-client'
require 'json'

EM.run do
  conn = EventMachine::WebSocketClient.connect("ws://localhost:9000/#{ARGV[0]}")
  prg = Random.new
  val = prg.rand(50.0)
  conn.callback do
    EM.add_periodic_timer 3 do 
      sign = prg.rand(100) > 50 ? :+ : :-
      val = val.send(sign, prg.rand(2))
      data = {type: 'data', temp_c: val}.to_json
    end
    puts 'started socket client... ' + ARGV[0]
  end

  conn.errback do |e|
    puts "Got error: #{e}"
  end

  conn.stream do |msg|
    puts "<#{msg}>"
    if msg.data == "done"
      conn.close_connection
    end
  end

  conn.disconnect do
    puts "gone"
    EM::stop_event_loop
  end
end