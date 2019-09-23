# console2es

A simple helper to take the syntax of kibana console and send requests
to Elasticsearch, without having the need of a kibana instance.

The kibana format looks like this

```
GET my-index/_search
{
  "query" : { "match_all": { } }
}

# comment is ignored
GET foo/_mappings
GET bar/_settings
```


## Installation

First, make sure you have crystal installed. See the [crystal install docs](https://crystal-lang.org/docs/installation/).

Second, run `crystal build --release src/console2es.cr` and use the `console2es` binary created in the directory.


## Usage

Specify an input file and the endpoint like this

```
console2es -i my-kibana-file -h http://localhost:9200
```

See also `console2es -h`

If a command has not a good 2xx return code, the response will be written on the
console.


## Development

Most likely you found a bug in this pretty raw tool.
In that case please write a failing test in `spec/console_parser_spec.cr`, fix it
and open a pull request. Alternatively open an issue with a sample snippet of
JSON and I'll take a look at it when possible.

You can run the tests locally by running `crystal spec`. 


## Contributing

1. Fork it (<https://github.com/spinscale/console2es/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [Alexander Reelsen](https://github.com/spinscale) - creator and maintainer
