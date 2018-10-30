# PbJsonParser

PbJsonParser parses JSON dumps generated by [protoc-gen-json](https://github.com/sourcegraph/prototools/blob/master/README.json.md) and returns the information of fields and associations of each message types.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pb_json_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pb_json_parser

## Usage
First, prepare .proto file.

```protobuf
// resources.proto
syntax = "proto3";
package south37.users_prototype;

import "google/protobuf/timestamp.proto";

message User {
  int32 id = 1;
  Profile profile = 2;
}

message Profile {
  int32 id = 1;
  google.protobuf.Timestamp birthday = 2;
}
```

Then, generate `.proto.json` by protoc with [protoc-gen-json](https://github.com/sourcegraph/prototools/blob/master/README.json.md) plugin.

```bash
$ REPOLIST=( \
>   sourcegraph.com/sourcegraph/prototools/cmd/protoc-gen-json \
> )
> for REPO in ${REPOLIST[@]}; do
>   if [ ! -d $GOPATH/src/$REPO ]; then
>     go get -u $REPO
>   fi
> done

$ protoc \
>   -I ./protos \
>   --json_out=out=resources.proto.json:./protos \
>   ./protos/resources.proto
```

Finally you can parse the json by `PbJsonParser`.

```ruby
[6] pry(main)> PbJsonParser.parse(json: File.read('./protos/resources.proto.json'), filename: 'resources.proto').map(&:to_h)
=> [
 {:name=>"User", :fields=>[{:name=>"id", :type=>"int32"}], :assocs=>[{:name=>"profile", :kind=>"has_one", :class_name=>"Profile"}]},
 {:name=>"Profile", :fields=>[{:name=>"id", :type=>"int32"}, {:name=>"birthday", :type=>".google.protobuf.Timestamp"}], :assocs=>[]}
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake true` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/south37/pb_json_parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
