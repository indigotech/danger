require 'find'

if !defined? @platform
  warn("No platform was provided to perform platform specific assertions")
  @platform = "" # avoid future crashes
end


########################
#    COMMON SECTION    #
########################

# moved files have a pattern that were  messing with file reading
modified_files = git.modified_files.select { |path| !path.include? "=>" }

# Comparing only readable files
modified_files = modified_files.reject { |f|  /.*\.(tgz|png|jpg)/.match(File.extname(f)) }

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

# Common files
files_to_check = ["Gemfile.lock", ".travis.yml", ".gitignore"]
# Node files
files_to_check += ["yarn.lock", "docker-compose.yml", "Procfile", "npm-shrinkwrap.json", "node_modules", "tasks/options/env.coffee"]
# iOS files
files_to_check += ["Cakefile", "fastlane/settings.yml.erb", "fastlane/Fastfile", "Podfile.lock"]
# Check if files were modified
(modified_files & files_to_check).each do |file|
  message("`#{file}` modified")
end

diff = github.pr_diff
# Ensure we keep using secure https:// references instead of http://
fail("Detected unsecure `http://` use in `#{file}` - `#{line}`") if diff =~ /\+\s*http:\/\/.*/


# Warn if 'Gemfile' was modified and 'Gemfile.lock' was not
if modified_files.include?("Gemfile")
  if !modified_files.include?("Gemfile.lock")
    warn("`Gemfile` was modified but `Gemfile.lock` was not")
  else
    message("`Gemfile` modified")
  end
end

modified_files.each do |file|
  begin
    File.foreach(file) do |line|
      line = line.gsub('\n','').strip
      # Make sure resolves merges or rebases conflict issues
      fail("Commited file without resolving merges/rebases conflict issues on `#{file}` - `#{line}`") if line =~ /^>>>>>>>/
      # Look for Amazon Secret keys in modified files
      warn("Possible amazon secret key hardcoded found in `#{file}`") if line =~ /(?<![A-Za-z0-9\/+=])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=])/ && file != "yarn.lock"
    end
    rescue
      message "Could not read file #{file}, does it really exist?"
    end
end

########################
#   FUNCTIONS SECTION  #
########################

def checkForNodeVersion(file, line)
  # Keep node version synced between declarations
  warn("`package.json` node version was modified. Remember to update node version on `.travis.yml`, `.nvmrc` and `README`!") if file && line && file == "package.json" && line =~ /"node":/
  warn("`.nvmrc` was modified. Remember to update node version on `.travis.yml`, `package.json` and `README`!") if file && file == ".nvmrc"
end

def checkForWeaklyTypedFunctionReturn(line)
  # Warn when a TypeScript file has a new function returning <any> instead of strongly typed.
  # There are several situation that need to return just 'any', so to avoid having too many false positives 
  #   we are checking just <any> for now
  warn("Possibly returning <any> in a function, prefer having a strongly typed return. `#{file}` at line `#{line}`.") if line =~ /<any>/im
end

def checkForNpmInstallGlobal(file, line)
  # Warn developers that they are not supposed to use this flag
  warn("`npm install` with flag `-g` was found in `#{file}` at `#{line}`. This is not recommended.") if line =~ /npm install -g/
end

########################
#   Node.JS SECTION    #
########################
if @platform == "nodejs"

  modified_files.each do |file|
    begin
      File.foreach(file) do |line|
        line = line.gsub('\n','').strip
        
        checkForNodeVersion(file, line)
        checkForNpmInstallGlobal(file, line)
      end
    rescue
      message "Could not read file #{file}, does it really exist?"
    end

    # Look for files with spefic extension in modified files
    ext = File.extname(file)
    case ext
    when ".env"
      message("`#{file}` was modified")
    when ".ts"
      begin
        File.foreach(file) do |line|
          line = line.gsub('\n','').strip

          checkForWeaklyTypedFunctionReturn(line)
        end
      rescue
        message "Could not read file #{file}, does it really exist?"
      end
    end

  end

  # Warn if 'console.log' was added
  diff = github.pr_diff
  warn("`console.log` added") if diff =~ /\+\s*console\.log/

  # Warn if 'package.json' was modified but 'yarn.lock' or 'shrinkwrap' was not
  yarn_exist = File.file?("yarn.lock")
  shrinkwrap_exist = File.file?("shrinkwrap")
  if modified_files.include?("package.json")
    if yarn_exist && !modified_files.include?("yarn.lock")
      warn("`package.json` was modified but `yarn.lock` was not")
    end
    if shrinkwrap_exist && !modified_files.include?("shrinkwrap")
      warn("`package.json` was modified but `shrinkwrap` was not")
    end
    # Fail when dependency version is used with `~` or `^`
    diff = github.pr_diff
    fail("Don't use `~` or `^` on dependencies version") if diff =~ /"[a-zA-Z0-9-]*":\s*"[~^]/
  end
end


########################
#      iOS SECTION     #
########################
if @platform == "ios"

  # Warn if 'Podfile' was modified but 'Podfile.lock' was not
  if modified_files.include?("Podfile")
    if !modified_files.include?("Podfile.lock")
      warn("`Podfile` was modified but `Podfile.lock` was not")
    else
      warn("`Podfile` was modified")
    end
  end

  # Warn that some changes can 'break' provisionings and sign certificates configurations
  if modified_files.include?("Cakefile")
    diff = github.pr_diff
    warn("Lines modified on `Cakefile` can missconfigure project provisionings and sign certificates") if diff =~ /(PROVISIONING_PROFILE_SPECIFIER|BUNDLE_ID|DEVELOPMENT_TEAM|CODE_SIGN_IDENTITY)/
  end

  check_next_line = false
  plist_files_paths = modified_files.select { |path| path.include?("Supporting") && path =~ /.*Info\.plist$/ }

  plist_files_paths.each do |file|
    begin
      File.foreach(file) do |line|
        line = line.gsub('\n','').strip
        # Warn that ATS Exception is set in plist
        warn("ATS Exception found in plist `#{file}`") if line =~ /NSAppTransportSecurity/
        # Warn that Landscape orientation is set in plist
        message("Landscape orientation is set in plist `#{file}`") if line =~ /UIInterfaceOrientationLandscape/
        # Warn Facebook ID hardcoded
        if check_next_line
          warn("Facebook App ID is hardcoded in plist `#{file}`") if line =~ /<string>\d*<\/string>/
          check_next_line = false
        end
        check_next_line = true if line =~ /FacebookAppID/
      end
    rescue
      message "Could not read file #{file}, does it really exist?"
    end
  end

  begin
    File.foreach("Podfile") do |line|
      line = line.gsub('\n','').strip
      # Warn pods being loaded from external git repos
      message("`Podfile` has pods being loaded from external git repos at `#{line}`") if line =~ /:git/
      # Warn when no version is specified
      warn("No version specified for pod at `#{line}`") if line =~ /pod\s*'[a-zA-Z0-9-]*'(?!,)/
    end
  rescue
    message "Could not read file #{file}, does it really exist?"
  end

  modified_files.each do |file|
    begin
      File.foreach(file) do |line|
        line = line.gsub('\n','').strip
        # Warn developers things that need to be done
        warn("`TODO` was added in `#{file}` at line `#{line}`") if line =~ /^(#\s*.*?|\/\/\s*.*?)(TO\s*.*?DO)/mi

        ext = File.extname(file)
        case ext
        when ".swift"
          # ignore commented lines
          next if line =~ /^ *\/\//m
          # Warn when forced unwrapping is used
          if line =~ /\w!\s*(.|\(|\{|\[|\]|\}|\))/m &&  #  check for any char followed by "!", ignoring if 
            !(line =~ /@IBOutlet/m) && #  - line starts with "@IBOutlet"
            !(line =~ /\".*!.*"/m) && #  - "!" is inside quotes (aka in a string)
            !(line =~ /(var|func) [^ ]* *(:|->) *[^ ]*!/m)  #  - `var variable: AnyType!` or `func anyname() -> AnyType! {`
            warn("Possible forced unwrapping found in `#{file}` at `#{line}`") 
          end
          # Warn print was added
          warn("`print(\"\")` was added in `#{file}` at line `#{line}`") if line =~ /print\(""\)/
          # Warn developers to use another alternatives
          warn("`fatalError` was added in `#{file}` at line `#{line}` is not possible use error handlers or throw an exception?") if line =~ /fatalError\(/
        end
      end
    rescue
      message "Could not read file #{file}, does it really exist?"
    end
  end

end

########################
#    Android SECTION   #
########################
if @platform == "android"
  
  modified_files.each do |file|
    ext = File.extname(file)
    case ext
    # Warn when a file .gradle is modified
    when ".gradle"
      message("`#{file}` was modified")
    end
    # Warn when a FileManifest.xml is modified
    message("`#{file}` was modified") if file =~ /Manifest\.xml/
  end
end

########################
#      Web SECTION     #
########################
if @platform == "web"
  modified_files.each do |file|
    begin
      File.foreach(file) do |line|
        line = line.gsub('\n','').strip
        
        checkForNodeVersion(file, line)
        checkForNpmInstallGlobal(file, line)
      end
    rescue
      message "Could not read file #{file}, does it really exist?"
    end

    ext = File.extname(file)
    case ext
    # Warn when a file .style is modified
    when ".styl"
      message("`#{file}` was modified")
    when ".ts"
      begin
        File.foreach(file) do |line|
          line = line.gsub('\n','').strip

          checkForWeaklyTypedFunctionReturn(line)
        end
      rescue
        message "Could not read file #{file}, does it really exist?"
      end
    end
  end
end
