class ConsoleParser

  def parse (input : String)
    snippets = Array(Snippet).new
    lines = input.split("\n")
      .reject { |line| line.starts_with?('#') }
      .reject { |line| line == "" }

    body = ""
    lines.each { |line|
      # resembling a HTTP method
      if (line.starts_with?(/^[a-zA-Z]/))
        # check if we need to add the body to the current snippet
        if body != ""
          snippets.last.body = body.chomp
          body = ""
        end

        method, endpoint = line.split(" ", 2)
        snippets << Snippet.new method, endpoint
      else
        body += line + "\n"
      end
    }
    if body != ""
      snippets.last.body = body.chomp
    end

    # TODO parse input and add to snippets
    snippets
  end

end

class Snippet

  getter method
  getter endpoint
  property body : String | Nil

  def initialize(@method : String, @endpoint : String)
    @body = nil
  end

end
