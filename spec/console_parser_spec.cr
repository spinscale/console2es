require "spec"
require "json"
require "../src/console_parser.cr"

describe ConsoleParser do

  parser = ConsoleParser.new

  it "works with a single request without body" do
    snippets = parser.parse %Q(GET /)
    snippets.size.should eq 1
    snippets.first.method.should eq "GET"
    snippets.first.endpoint.should eq "/"
  end

  it "ignores comments" do
    snippets = parser.parse %Q(#foo\nGET /\n#bar)
    snippets.size.should eq 1
    snippets.first.method.should eq "GET"
    snippets.first.endpoint.should eq "/"
  end

  it "works with a single request with body" do
    snippets = parser.parse %Q(POST /_search\n{ "foo": "bar" })
    snippets.size.should eq 1
    snippets.first.method.should eq "POST"
    snippets.first.endpoint.should eq "/_search"
    snippets.first.body.should eq %Q({ "foo": "bar" })
  end

  it "works with a more complex example" do
    input = %Q(GET /

# ignore comment and above empty line

POST foo/_search
{
  "query" : { "match_all" : { } }
}
get bar
# the above should work as well
)
    snippets = parser.parse input
    snippets.size.should eq 3
    snippets[0].method.should eq "GET"
    snippets[1].method.should eq "POST"
    snippets[2].method.should eq "get"
    snippets[0].endpoint.should eq "/"
    snippets[1].endpoint.should eq "foo/_search"
    snippets[2].endpoint.should eq "bar"
    snippets[0].body.should be_nil
    snippets[2].body.should be_nil
    # ensure JSON is the same
    expectedJson = JSON.parse %Q({ "query" : { "match_all" : {}} })
    snippetsJson = JSON.parse snippets[1].body.to_s
    snippetsJson.should eq expectedJson
  end
end
