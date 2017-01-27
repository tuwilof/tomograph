# tomograph

This is make API Tomogram

## Install

config/application.rb

```
require 'tomograph'
```

## Config

### documentation

For gem needed by a ```drafter``` generate and save ```yaml``` file, and then turn it on config.
```
drafter doc/api.apib -o doc/api.yaml
```

```ruby
Tomograph.configure do |config|
  config.documentation = 'doc/api.yaml'
end
```

Then you can use the API tomogram by using the following call:

```ruby
Tomograph::Tomogram.json
```

API tomogram return to json format.

### prefix
Default empty String. This is prefix for url if in docimentation URI short .

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
