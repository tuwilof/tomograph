# Tomograph [![Build Status](https://travis-ci.org/funbox/tomograph.svg?branch=master)](https://travis-ci.org/funbox/tomograph) [![Gem Version](https://badge.fury.io/rb/tomograph.svg)](https://badge.fury.io/rb/tomograph)

<a href="https://funbox.ru">
  <img src="https://funbox.ru/badges/sponsored_by_funbox_compact.svg" alt="Sponsored by FunBox" width=250 />
</a>

Convert API Blueprint to JSON Schema and search.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tomograph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tomograph

## Usage

```ruby
require 'tomograph'
```

```ruby
tomogram = Tomograph::Tomogram.new(apib_path: '/path/to/doc.apib')
```

### Command line tool

The command line tool allows you to convert files from API Blueprint or API Elements to JSON Schema.
```
tomograph doc.apib doc.json
```
See
```
tomograph -h
```
for details on usage.

## Convert

```ruby
tomogram.to_json
```

Example input:
```apib
FORMAT: 1A
HOST: http://test.local

# project

# Group project

Project

## Authentication [/sessions]

### Sign In [POST]

+ Request (application/json)

    + Attributes
     + login (string, required)
     + password (string, required)
     + captcha (string, optional)

+ Response 401 (application/json)

+ Response 429 (application/json)

+ Response 201 (application/json)

    + Attributes
     + confirmation (Confirmation, optional)
     + captcha (string, optional)
     + captcha_does_not_match (boolean, optional)


# Data Structures

## Confirmation (object)
  + id (string, required)
  + type (string, required)
  + operation (string, required)
```

Example output:
```json
[
  {
    "path": "/sessions",
    "method": "POST",
    "content-type": "application/json",
    "request": {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "type": "object",
      "properties": {
        "login": {
          "type": "string"
        },
        "password": {
          "type": "string"
        },
        "captcha": {
          "type": "string"
        }
      },
      "required": [
        "login",
        "password"
      ]
    },
    "responses": [
      {
        "status": "401",
        "content-type": "application/json",
        "body": {}
      },
      {
        "status": "429",
        "content-type": "application/json",
        "body": {}
      },
      {
        "status": "201",
        "content-type": "application/json",
        "body": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "type": "object",
          "properties": {
            "confirmation": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "string"
                },
                "type": {
                  "type": "string"
                },
                "operation": {
                  "type": "string"
                }
              },
              "required": [
                "id",
                "type",
                "operation"
              ]
            },
            "captcha": {
              "type": "string"
            },
            "captcha_does_not_match": {
              "type": "boolean"
            }
          }
        }
      }
    ]
  }
]
```

## Search

### find_request

```ruby
request = tomogram.find_request(method: 'GET', path: '/status/1?qwe=rty')
```

### find_request

```ruby
request = tomogram.find_request_with_content_type(method: 'GET', path: '/status/1?qwe=rty', content_type: 'application/json')
```

### find_responses


```ruby
responses = request.find_responses(status: '200')
```

## Other methods

### prefix_match?

This can be useful if you use a prefix.

```ruby
tomogram.prefix_match?('http://local/api/v2/users')
```

## Params

Example:

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', apib_path: '/path/to/doc.apib')
```

or

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', drafter_yaml_path: '/path/to/doc.yaml')
```

or

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', tomogram_json_path: '/path/to/doc.json')
```

### apib_path

Path to API Blueprint documentation. There must be an installed [drafter](https://github.com/apiaryio/drafter) to parse it.

### drafter_yaml_path

Path to API Blueprint documentation pre-parsed with `drafter` and saved to a YAML file.

### tomogram_json_path

Path to API Blueprint documentation converted with `tomograph` to a JSON file.

### prefix

Default empty String. Prefix of API requests. Example: `'/api'`.

### to_resources

Hash resource with requests.
The result for the example above:
```ruby
{
  '/sessions' => ['POST /sessions']
}
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
