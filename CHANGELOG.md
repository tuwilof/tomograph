# Change log

### 3.1.0 - 2021-02-09

* features
  * support Swagger/OpenAPI 2.0 [#47](https://github.com/funbox/tomograph/issues/47)
  * support OpenAPI 3.0 [#50](https://github.com/funbox/tomograph/issues/50)
* removed
  * delete travis [#45](https://github.com/funbox/tomograph/issues/45)

### 3.0.1 - 2020-10-14

* removed
  * delete apib_path [#31](https://github.com/funbox/tomograph/issues/31)
  * delete drafter_4_apib_path [#32](https://github.com/funbox/tomograph/issues/32)
  * replace drafter_yaml_path with drafter_4_yaml_path [#33](https://github.com/funbox/tomograph/issues/33)
  * delete crafter_apib_path [#34](https://github.com/funbox/tomograph/issues/34)
  * delete multi_json [#35](https://github.com/funbox/tomograph/issues/35)

### 3.0.0 - 2020-08-27

* features
  * support multi request for one resource path [#27](https://github.com/funbox/tomograph/issues/27)
* removed
  * delete support drafter 3 [#29](https://github.com/funbox/tomograph/issues/29)

### 2.5.4 - 2020-04-06

* fixed warnings on ruby 2.7
* updated dependences

# Change log

### 2.5.3 - 2020-03-10

* bug fixes
  * fix parser status to string

### 2.5.2 - 2020-01-10

* bug fixes
  * fix parser for new crafter version

### 2.5.1 - 2019-12-09

* bug fixes
  * fix content_type parsing.

### 2.5.0 - 2019-05-28

* features
  * аdded support for documents with pre-parsed by drafter 4.

### 2.4.2 - 2018-11-29

* bug fixes
  * replace '/' with '#' in filenames in JSON split mode

### 2.4.1 - 2018-11-9

* bug fixes
  * use parens for IDs in JSON filenames

### 2.4.0 - 2018-11-9

* features
  * add '--split' option for command-line tool

### 2.3.0 - 2018-09-27

* features
  * add exclude-description option for command-line tool

### 2.2.1 - 2018-07-06

* bug fixes
  * fix path missing prefix in Tomogram JSON to_resources

### 2.2.0 - 2018-07-05

* API changes
  * Tomogram: add to_a method
* deprecations
  * Tomogram: to_hash method
* features
  * add command-line tool
  * include Action's "resource" in serialization to JSON
  * add support for loading Tomogram JSON

### 2.1.0 - 2018-03-16

* features
  * add content-type for requests and responses
  * add find_request_with_content_type

### 2.0.1 - 2018-03-02

* bug fixes
  * moved require yaml

### 2.0.0 - 2018-03-02

* removed
  * dependence on rails

### 1.2.0 - 2017-10-18

* features
  * add prefix_match? method

### 1.1.0 - 2017-06-15

* features
  * hash resource with request
