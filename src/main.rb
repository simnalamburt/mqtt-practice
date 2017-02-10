# frozen_string_literal: true
require 'mqtt'
require 'tomlrb'

# Parse ARGV
if ARGV.length == 1 and ARGV[0] == 'pub'
  MODE = :publish
elsif ARGV.length == 1 and ARGV[0] == 'sub'
  MODE = :subscribe
else
  puts <<END
usage: run [pub | sub]

Commands:
   pub    Run publishing sample
   sub    Run subscribing sample
END
  exit 1
end

# Load configs
config = Tomlrb.load_file('secret.toml', symbolize_keys: true)
host = config.dig(:config, :hostname)
port = config.dig(:config, :port)
username = config.dig(:credentials, :username)
password = config.dig(:credentials, :password)

# Connect to MQTT broker
print '연결중 ... '
MQTT::Client.connect(host: host, port: port, username: username, password: password) do |c|
  puts "\e[32m완료!\e[0m"

  case MODE
  when :publish
    loop.with_index do |_, i|
      c.publish('mqtt-practice', "야호 #{i}")
      sleep 1
    end
  when :subscribe
    c.get('mqtt-practice') do |topic, message|
      puts "#{topic}: #{message}"
    end
  end
end
