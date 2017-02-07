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
```bash
$ bundle exec danger local
```

## Usage on CI

1. To execute on CI, add the following command preferably before building your code
```bash
$ bundle exec danger --dangerfile=path/to/Dangerfile
```

## Troubleshooting

### It is asking me for a `DANGER_GITHUB_API_TOKEN`

> Local repository was not found on GitHub. If you're trying to test a private repository please provide a valid API token through DANGER_GITHUB_API_TOKEN environment variable.

1. Create a github [Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
2. Export it to an environment variable
```bash
$ export DANGER_GITHUB_API_TOKEN=your token here
```