########################
#    COMMON SECTION    #
########################

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

warn("'Gemfile' modified") if git.modified_files.include?("Gemfile")
warn("'Gemfile.lock' modified") if git.modified_files.include?("Gemfile.lock")
warn("'travis.yml' modified") if git.modified_files.include?(".travis.yml")
warn("'.gitignore' modified") if git.modified_files.include?(".gitignore")

# Warn if 'Gemfile' was modified and 'Gemfile.lock' was not
if git.modified_files.include?("Gemfile")
  if !git.modified_files.include?("Gemfile.lock")
    warn("'Gemfile' was modified but 'Gemfile.lock' was not")
  end
end

# Make sure resolves merges or rebases conflict issues
git.modified_files.each do |file|
  File.foreach(file) do |line|
    fail("Commited file without resolving merges/rebases conflict issues on `#{file}` - `#{line}`") if line =~ />>>>>>>/
  end
end

########################
#    Node SECTION      #
########################

warn("'yarn.lock' modified") if git.modified_files.include?("yarn.lock")
warn("'docker-compose.yml' modified") if git.modified_files.include?("docker-compose.yml")
warn("'Procfile' modified") if git.modified_files.include?("Procfile")
warn("'npm-shrinkwrap.json' modified") if git.modified_files.include?("npm-shrinkwrap.json")
warn("'node_modules' modified") if git.modified_files.include?("node_modules")
warn("'env.coffee' modified") if git.modified_files.include?("tasks/options/env.coffee")

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

git.modified_files.each do |file|
  # Look for Amazon Secret keys in modified files
  File.foreach(file) do |line|
    warn("Amazon secret key hardcoded in `#{file}` at `#{line}`") if line =~ /(?<![A-Za-z0-9\/+=])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=])/
  end

  # Look for files with spefic extension in modified files
  ext = File.extname(file)
  case ext
  when ".env"
    warn("file with extension .env changed")
  when ".nvmrc"
    warn("file with extension .nvmrc changed")
  end

end

# Warn if 'console.log' was added
diff = github.pr_diff
warn("'console.log' added") if diff =~ /\+\s*console\.log/

# Warn if 'package.json' was modified but 'yarn.lock' or 'shrinkwrap' was not
yarn_exist = File.file?("yarn.lock")
shrinkwrap_exist = File.file?("shrinkwrap")
if git.modified_files.include?("package.json")
  if yarn_exist && !git.modified_files.include?("yarn.lock")
    warn("'package.json' was modified but 'yarn.lock' was not")
  end
  if shrinkwrap_exist && !git.modified_files.include?("shrinkwrap")
    warn("'package.json' was modified but 'shrinkwrap' was not")
  end
end

########################
#      iOS SECTION     #
########################

warn("'Cakefile' modified") if git.modified_files.include?("Cakefile")
warn("'settings.yml.erb' modified") if git.modified_files.include?("fastlane/settings.yml.erb")
warn("'Fastfile' modified") if git.modified_files.include?("fastlane/Fastfile")

# Warn if 'Podfile' was modified but 'Podfile.lock' was not
if git.modified_files.include?("Podfile")
  if !git.modified_files.include?("Podfile.lock")
    warn("'Podfile' was modified but 'Podfile.lock' was not")
  end
end

# Warn that some changes can 'break' provisionings and sign certificates configurations
if git.modified_files.include?("Cakefile")
  diff = github.pr_diff
  warn("Lines modified on Cakefile can missconfigure project provisionings and sign certificates") if diff =~ /(PROVISIONING_PROFILE_SPECIFIER|BUNDLE_ID|DEVELOPMENT_TEAM|CODE_SIGN_IDENTITY)/
end

File.foreach("Schutz/Supporting\ Files/Info.plist") do |line|
  # Warn that ATS Exception is set in plist
  warn("ATS Exception found in plist") if line =~ /NSAppTransportSecurity/
  # Warn that Landscape orientation is set in plist
  warn("Landscape orientation is set in plist") if line =~ /UIInterfaceOrientationLandscape/
end






########################
#    Android SECTION   #
########################
