# Tomograph 

Convert API Blueprint, Swagger and OpenAPI to minimal routes with JSON Schema. For ease of use and creation of new tools.

Will look like

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

## Installation

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

### In code

#### OpenAPI 2.0

Also Swagger

```ruby
require 'tomograph'

tomogram = Tomograph::Tomogram.new(openapi2_json_path: '/path/to/doc.json')
```

#### OpenAPI 3.0

Also OpenAPI

```ruby
require 'tomograph'

tomogram = Tomograph::Tomogram.new(openapi3_yaml_path: '/path/to/doc.yaml')
```

#### API Blueprint

First you need to install [drafter](https://github.com/apiaryio/drafter).
Works after conversion from API Blueprint to API Elements (in YAML file) with Drafter.

That is, I mean that you first need to do this

```bash
drafter doc.apib -o doc.yaml
```

and then

```ruby
require 'tomograph'

tomogram = Tomograph::Tomogram.new(drafter_yaml_path: '/path/to/doc.yaml')
```

#### Tomograph

To use additional features of the pre-converted

```ruby
require 'tomograph'

tomogram = Tomograph::Tomogram.new(tomogram_json_path: '/path/to/doc.json')
```

#### prefix
Default: `''`

You can specify API prefix and path to the spec using one of the possible formats:

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', drafter_yaml_path: '/path/to/doc.yaml')
```

```ruby
Tomograph::Tomogram.new(prefix: '/api/v2', tomogram_json_path: '/path/to/doc.json')
```

#### to_json
Use `to_json` for converting to JSON, example from API Blueprint:

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

#### to_a
```ruby
tomogram.to_a
```

#### find_request
```ruby
request = tomogram.find_request(method: 'GET', path: '/status/1?qwe=rty')
```

#### find_request_with_content_type
```ruby
request = tomogram.find_request_with_content_type(method: 'GET', path: '/status/1?qwe=rty', content_type: 'application/json')
```

#### `find_responses`
```ruby
responses = request.find_responses(status: '200')
```

#### prefix_match?
This may be useful if you specify a prefix.

```ruby
tomogram.prefix_match?('http://local/api/v2/users')
```

#### to_resources
Maps resources for API Blueprint with possible requests.

Example output:

```ruby
{
  '/sessions' => ['POST /sessions']
}
```

### Command line tool

CLI allows you to convert files from API Blueprint (API Elements), Swagger and OpenAPI to JSON Schema.

Run CLI with `-h` to get detailed help:

```bash
tomograph -h
```

To specify the handler version use the `-d` flag:

#### OpenAPI 2.0
```bash
tomograph -d openapi2 openapi2.json tomogram.json
```

#### OpenAPI 3.0
```bash
tomograph -d openapi3 openapi3.yaml doc.json
```

#### API Blueprint
```bash
tomograph -d 4 apielemetns.yaml doc.json
```

#### exclude-description

Exclude "description" keys from json-schemas.

```bash
tomograph -d 4 apielemetns.yaml doc.json --exclude-description
```

#### split

Split output into files by method. Output in dir path.

```bash
tomograph -d 4 --split apielemetns.yaml jsons/
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
