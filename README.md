# danger-taqtile

Danger base file for Taqtile projects

## Instalation

On your project root folder:

1. Create a `Gemfile` with
```ruby
source "https://rubygems.org"
gem "danger", "4.2.1"
```
1. Execute `$ bundle  install`
1. Create a `Dangerfile` with
```ruby
@platform = "nodejs" # Possible platforms are "nodejs", "ios", "android" and "web"
danger.import_dangerfile(github: "indigotech/danger", branch: "1.0.1") # replace version by latest on "Releases" section
```

## Usage Locally

1. To test your PR locally, simply execute
```bash
$ bundle exec danger local
```

## Usage on CI

1. Add angithub access token as `DANGER_GITHUB_API_TOKEN` environment variable to enable `Danger` to access Github PR and add comments. 
  - If you already have a token variable you can use something like the following:
  ```bash
  export DANGER_GITHUB_API_TOKEN=$YOUR_CURRENT_GITHUB_TOKEN_VARIABLE
  ```
1. To execute on CI, add the following command preferably before building your code and after the environment variable was defined.
```bash
$ bundle exec danger --dangerfile=path/to/Dangerfile
```


## What is currently being checked

### Common

- [x] Warn if some files/folders to be changed/committed like `.gitignore`, `Gemfile`, `Gemfile.lock`, `.travis.yml`
- [x] `>>>` Strings to make sure rebase was successful
- [x] Big PRs
- [x] Warn when `Gemfile` was modified and `Gemfile.lock` was not
- [x] Fail when no description is provided

### Node

- [x] Warn if some files/folders to be changed/committed like `yarn.lock`, `docker-compose.yml`, `Procfile`, `npm-shrinkwrap.json`, `node_modules`, `env.coffee`
- [x] Warn when Amazon Secret Key is hardcoded
- [x] Warn when `npm install -g` is used
- [x] Warn when `.env` or `.nvmrc` files are modified
- [x] Warn when `console.log` is added 
- [x] Warn when `package.json` was modified and `yarn.lock` or `shrinkwrap` was not
- [x] Warn if node version is different between .travis.yml, .nvmrc, package.json and README (or just warn if node version has change just in one of these locations)
- [x] At packages.json every package should have its version fixed (do not use ^ or ~), or explicitly set the major and minor versions (ie.: 1.2.x)

### iOS

- [x] Warn if some files/folders to be changed/committed like `Cakefile`, `settings.yml.erb`, `Fastfile`
- [x] Warn when `Podfile` was modified and `Podfile.lock` was not
- [x] Warn if changes made in Cakefile may 'break' provisionings and sign certificates configurations
- [x] Warn when ATS Exception is set in plist
- [x] Warn when Landscape orientation is set in plist
- [x] Warn when Facebook ID is hardcoded in plist
- [x] Warn when pod is being loaded from external git repos
- [x] Warn when `TODO` is added
- [x] Warn when `print(“”)` is added
- [x] Warn when `fatalError` is added
- [x] Warn if Podfile has pods should not using fixed versions
- [x] Warn if forced unwrapping was found

### Android

- [x] Warn when `.gradle` or `Manifest.xml` files are modified

### Web

- [x] Warn if CSS files were changed

## Troubleshooting

### It is asking me for a `DANGER_GITHUB_API_TOKEN`

> Local repository was not found on GitHub. If you're trying to test a private repository please provide a valid API token through DANGER_GITHUB_API_TOKEN environment variable.

1. Create a github [Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
2. Export it to an environment variable
```bash
$ export DANGER_GITHUB_API_TOKEN=your token here
```