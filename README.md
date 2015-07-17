# Gooddata::Viz

Since Protoviz is an awesome tool and the native display of models in GoodData could use some love (despite them using Protoviz as well) I created this simple gem + CLI tool. It can 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gooddata-viz'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gooddata-viz

There are some prerequisites and mainly I am talking about protoviz itself. If you are on Mac you can easily install via

    $ brew install graphviz

## Usage
Main task is to be able to generate model images from CLI. You can generate the images either from a live porject or from a file stored on your harddrive

### Image from live project
You can invoke it like this

    $ gooddataviz -p tywaryfht8k81ferrsqpuf3mcuqg9qgc -U john@gmail.com -P password

This will by default produce 3 files called `model.png`, `model.dot` and `model.svg`. If you have your credentials stored in ~/.gooddata (see [storing credentials locally](https://github.com/gooddata/gooddata-ruby-examples/blob/master/01_getting_started/03_connecting_to_gooddata.asciidoc#discussion)) you can omit the credentials an just provide the pid

    $ gooddataviz -p tywaryfht8k81ferrsqpuf3mcuqg9qgc

For this to work you have to be connected to internet. The tool will connect to the project extract some information (this can take ~30 secs) and then generate the image.

### Image from exported model
This works similarly but there are couple of differences. You do not need to be connected to the internet to generate the images (given you have the file). This is much faster.

    $ gooddataviz -f path_to_file.json

#### Obtaining the model
You can obtain the file using GoodDat SDK see [Get the model](https://github.com/gooddata/gooddata-ruby-examples/blob/master/12_working_with_blueprints/02_getting_project_blueprint.asciidoc)


## Display conventions
There are couple of visual hints that should make it easier to see important things.

### Date dimensions
Date dimensions are filled with light blue color

### Fact tables
Fact table is filled with light yellow(ish) color. Fact table is defined as a dataset that is not referenced by another dataset. It does not mean that is has to include exclusively facts.

### References
References are by default leading out of references in case you are rendering with `dot` engine (hierarchichal layout). If you are using any other engine the references are connected to the dataset itself. The arrow is from reference to the referenced dataset (from fact table to its dimension).

### Fact
Fact is marked with `#` in dataset

### Attribute
Attribute is marked with `a` in dataset

### Anchor/Connection point
Anchor is marked with `*` in dataset

## Parameters

There are several parameters to influence the functioning of the visualizer.

#### base_name
base_name is the file under which the images (and dotfile) will be generated. If you pass `filename` following files will be generated `filename.svg`, `filename.dot` and `filename.png`.

#### engine
engine parameter is deciding which layouting engine of graphviz the tool uses. This is a subject to change.

#### include_dates
Sometimes the model is so big that you might want to stop displaying pieces of model. This will remove date dimensions and references to them.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gooddata-viz. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

