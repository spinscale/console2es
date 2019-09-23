require "option_parser"
require "http/client"
require "colorize"
require "json"
require "./console_parser"

VERSION = "0.1.0"

filename="-"
endpoint = "http://localhost:9200"
auth = nil
display_all_responses = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: console2es [arguments]"
  parser.on("-i FILE", "--input-file=FILE", "File to read from, if none is specified, STDIN is tried") { |file| filename=file }
  parser.on("-h host", "--host=host", "Host, default http://localhost:9200") { |host| endpoint=host }
  parser.on("-u user:pass", "--user=user:pass", "Optional basic authentication") { |authentication| auth=authentication }
  parser.on("-a", "--all", "Show all HTTP responses regardless of errors") { display_all_responses = true }
  parser.on("-v", "--version", "Version info and exit") {
      puts VERSION
      exit(0)
    }
    parser.on("--help", "Show this help") {
      puts parser
      exit(0)
    }
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
end

# check if we need to read from stdin
if filename == "-"
  isPiped = LibC.isatty(0) == 0
  if isPiped == false
    puts "No input received from STDIN, exiting"
    puts "Make sure you are getting input from stdin!"
    exit
  end

  input = STDIN.gets_to_end
else
  # check if file exists
  if File.exists?(filename) && !File.empty?(filename)
    input = File.read filename
  else
    puts "File #{filename} does not exist or is empty. Exiting"
    exit
  end
end

# parse all the requests
parser = ConsoleParser.new
snippets = parser.parse input

# bail without any snippets
if snippets.empty?
  puts "Could not find any snippets in #{filename}"
  exit
end

# try to reach Elasticsearch '/' endpoint
client = HTTP::Client.new URI.parse(endpoint)
if auth != nil
  username, password = auth.to_s.split(/:/, 2)
  client.basic_auth username, password
end
response = client.get "/"

case response.status_code
when 200
when 401
  STDOUT.print "GET / "
  STDOUT.print "unauthorized\n".colorize(:yellow)
  STDOUT.print " (ran as a connection test on start up)\n"
else
  STDOUT.print "error".colorize(:red)
  STDOUT.print ". Exiting...\n"
  exit
end

headers = HTTP::Headers{"Content-Type" => "application/json"}
# parse file and sent data
snippets.each { |snippet|
  method = snippet.method.upcase
  endpoint = snippet.endpoint
  # dirty alignment hack
  STDOUT.printf "%-20s ", method + " " + endpoint
  req = HTTP::Request.new snippet.method.upcase, snippet.endpoint, headers
  if snippet.body != Nil
    req.body = snippet.body
  end
  response = client.exec req
  if response.status_code >= 200 && response.status_code < 300
    STDOUT.print "OK\n".colorize(:green)
    if display_all_responses
      STDOUT.print JSON.parse(response.body).to_pretty_json.colorize(:green)
      STDOUT.print '\n'
    end
  elsif response.status_code == 401
    STDOUT.print "unauthorized\n".colorize(:yellow)
  else
    STDOUT.print "error".colorize(:red)
    STDOUT.print "\n"
    STDOUT.print JSON.parse(response.body).to_pretty_json.colorize(:light_red)
    STDOUT.print "\n"
  end
}
