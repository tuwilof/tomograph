# Tomograph 

[![Build Status](https://travis-ci.org/funbox/tomograph.svg?branch=master)](https://travis-ci.org/funbox/tomograph) [![Gem Version](https://badge.fury.io/rb/tomograph.svg)](https://badge.fury.io/rb/tomograph)

Convert API Blueprint to JSON Schema and search.

## Installation

First you need to install [drafter](https://github.com/apiaryio/drafter).

Then add this line to your application's Gemfile:

```ruby
gem 'tomograph'
```

After that execute:

```bash
$ bundle
```

Or install the gem by yourself:

```bash
$ gem install tomograph
```

## Usage

```ruby
require 'tomograph'

tomogram = Tomograph::Tomogram.new(apib_path: '/path/to/doc.apib')
```

### Command line tool

CLI allows you to convert files from API Blueprint or API Elements to JSON Schema.

```bash
tomograph doc.apib doc.json
```

There is also support for documents pre-parsed by [drafter](https://github.com/apiaryio/drafter) versions 3 and 4, or `crafter`. 
To specify the handler version use the `-d` flag:

```bash
tomograph -d 4 doc_by_drafter4.yaml doc.json
```

Run CLI with `-h` to get detailed help:

```bash
tomograph -h
```

## Convert

Use `to_json` for converting APIB to JSON:

```ruby
tomogram.to_json
```

<details>
  <summary>Example input</summary>
  
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
</details>

<details>
  <summary>Example output</summary>
  
  ```json
  [
    {
      "path": "/sessions",
      "method": "POST",
      "content-type": "application/json",
      "requests": [{
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
      }],
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
</details> 

## Search

Use these methods to search through parsed API Blueprint spec to get request => responses hash maps.

### `find_request`

```ruby
request = tomogram.find_request(method: 'GET', path: '/status/1?qwe=rty')
```

### `find_request_with_content_type`

```ruby
request = tomogram.find_request_with_content_type(method: 'GET', path: '/status/1?qwe=rty', content_type: 'application/json')
```

### `find_responses`

```ruby
responses = request.find_responses(status: '200')
```

## Other methods

### `prefix_match?`

This may be useful if you specify a prefix.

```ruby
tomogram.prefix_match?('http://local/api/v2/users')
```

### `to_resources`

Maps resources with possible requests.

Example output:

```ruby
{
  '/sessions' => ['POST /sessions']
}
```

## Constructor params

You can specify API prefix and path to the spec using one of the possible formats:

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', apib_path: '/path/to/doc.apib')
```

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', drafter_yaml_path: '/path/to/doc.yaml')
```

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', tomogram_json_path: '/path/to/doc.json')
```

### `apib_path`

Path to API Blueprint documentation. There must be an installed [drafter](https://github.com/apiaryio/drafter) to parse it.

### `drafter_yaml_path`

Path to API Blueprint documentation pre-parsed with `drafter` and saved to a YAML file.

### Drafter v4 & Crafter support

If you are using a `drafter v4`, you should use `drafter_4_apib_path` and `drafter_4_yaml_path` respectively. 

In case when you want to use `сrafter`, then you should pass these params: `crafter_apib_path`, `crafter_yaml_path`. 

### `tomogram_json_path`

Path to API Blueprint documentation converted with `tomograph` to a JSON file.

### `prefix`

Default: `''`

Prefix for API requests. 

Example: `'/api'`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
