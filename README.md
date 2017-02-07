# danger-taqtile

Danger base file for Taqtile projects

## Instalation

1. Create a `Gemfile` with
```ruby
source "https://rubygems.org"
gem "danger"
```
1. Execte `$ bundle  install`
1. Create a `Dangerfile` with
```ruby
@platform = "nodejs" # Possible platforms are "nodejs", "ios", "android" and "web"
danger.import_dangerfile(github: "indigotech/danger", branch: "1.0.0")
```

## Usage Locally

1. To test your PR locally, simply execute
```
$ bundle exec danger local
```

## Usage on CI

1. To execute on CI, add the following command preferably before building your code
```
$ bundle exec danger --dangerfile=path/to/Dangerfile
```