require 'find'

if !defined? @platform
  warn("No platform was provided to perform platform specific assertions")
  @platform = "" # avoid future crashes
end

########################
#   FUNCTIONS SECTION  #
########################

def checkForFile(file)
  checkForFileCommon(file)
  case @platform
  when "nodejs"
    checkForFileNode(file)
  when "ios"
    checkForFileIos(file)
  when "android"
    checkForFileAndroid(file)
  when "web"
    checkForFileWeb(file)
  end
end

def checkForFileCommon(file)
  checkHttps(file)
  checkRebase(file)
  checkAmazonKeys(file)
end

def checkForFileNode(file)
  checkForNpmInstallGlobal(file)
  checkForEnginesVersion(file)
  validateSpecificExtensions(file)
  checkForConsoleLog(file)
end

def checkForFileIos(file)
  checkTodo(file)
  validateSwiftFiles(file)
  checkHardcodedNib(file)
end

def checkForFileAndroid(file)
  ext = File.extname(file)
  case ext
  # Warn when a file .gradle is modified
  when ".gradle"
    message("`#{file}` was modified")
  end
  # Warn when a FileManifest.xml is modified
  message("`#{file}` was modified") if file =~ /Manifest\.xml/
end

def checkForFileWeb(file)
  checkForEnginesVersion(file)
  checkForNpmInstallGlobal(file)
  validateSpecificExtensions(file)
  checkForConsoleLog(file)
end

def checkForRegex(file, regex)
  fileDiff = git.diff_for_file(file)
  resultMatches = fileDiff.patch.scan(regex)
  resultMatches
end

def exceptionMessages(file)
  if File.file?(file)
    message "Something went wrong checking `#{file}`. Check your Dangerfile"
  else
    message "One of modified files could not be read, does it really exist?"
  end
end

########################
#    NODE FUNCTIONS    #
########################

def checkForEnginesVersion(file)
  # Keep engines version synced between declarations
  if file == "package.json"
    # fileDiff = git.diff_for_file(file)
    engines = ["node","npm","yarn"]
    engines.each do |engine|
      engineVersionMatches = checkForRegex(file, /\+.*(\"#{engine}\")/)
      engineVersionMatches.each do |engineVersionMatch|
        stripMatch = engineVersionMatch[0].gsub!('"', '`')
        warn("#{stripMatch} version was modified in `package.json`. Remember to update #{stripMatch} version on `.travis.yml`, `.nvmrc` and `README`!") if engineVersionMatch
      end
    end
  end
  warn("`.nvmrc` was modified. Remember to update node version on `.travis.yml`, `package.json` and `README`!") if file && file == ".nvmrc"
end

def checkForWeaklyTypedFunctionReturn(file)
  # Warn when a TypeScript file has a new function returning <any> instead of strongly typed.
  # There are several situation that need to return just 'any', so to avoid having too many false positives
  #   we are checking just <any> for now
  returnAnyMatches = checkForRegex(file, /\+.*<any>/i)
  returnAnyMatches.each do |returnAnyMatch|
    warn("Possibly returning 'any' in a function, prefer having a strongly typed return. `#{file}` at line `#{returnAnyMatch}`.") if returnAnyMatch
  end
end

def checkForConsoleLog(file)
  # Warn when dev add `console.log`
  returnConsoleLogMatches = checkForRegex(file, /\+\s*console\.log.*/)
  returnConsoleLogMatches.each do |returnConsoleLogMatch|
    warn("`console.log` was added in `#{file}` at line `#{returnConsoleLogMatch}`.") if returnConsoleLogMatch
  end
end

def checkForNpmInstallGlobal(file)
  # Warn developers that they are not supposed to use this flag
  rejected_files = ["README.md"]
  if !rejected_files.include?(file)
    npmInstallMatches = checkForRegex(file, /\+.*npm install (-g|--global)/)
    npmInstallMatches.each do |npmInstallMatch|
      fail("`npm install` with flag `-g` or `--global` was found in `#{file}`. This is not recommended.") if npmInstallMatch
    end
  end
end

def validatePackageJson(modified_files, diff)
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
    fail("Don't use `~` or `^` on dependencies version") if diff =~ /\+.*"[a-zA-Z0-9-]*":\s*"[~^]/
  end
end

def validateSpecificExtensions(file)
  # Look for files with spefic extension in modified files
  ext = File.extname(file)
  case ext
  when ".env"
    message("`#{file}` was modified")
  when ".styl"
    message("`#{file}` was modified")
  when ".ts"
    begin
      checkForWeaklyTypedFunctionReturn(file)
    rescue
      exceptionMessages(file)
    end
  end
end

########################
#   COMMON FUNCTIONS   #
########################

def checkHttps(file)
  # Ensure we keep using secure https:// references instead of http://
  ignoreWarn = !!(file =~ /.*\/(drawable|layout)\/.*/)
  if !ignoreWarn
    httpMatches = checkForRegex(file, /\+.*http:\/\/.*/)
    httpMatches.each do |httpMatch|
      warn("Detected unsecure `http://` use in `#{file}` section `#{httpMatch}`") if httpMatch
    end
  end
end

def checkRebase(file)
  # Make sure resolves merges or rebases conflict issues
  rebaseMatches = checkForRegex(file, /^>>>>>>>/)
  rebaseMatches.each do |rebaseMatch|
    fail("Commited file without resolving merges/rebases conflict issues on `#{file}` - `#{rebaseMatch}`") if rebaseMatch
  end
end

def checkAmazonKeys(file)
  rejected_files = ["yarn.lock", "Podfile.lock", "Gemfile.lock"]
  ext = File.extname(file)
  rejected_files << file if ext == (".xib")
  # Look for Amazon Secret keys in modified files
  amazonKeyMatches = checkForRegex(file, /\+.*(?<![A-Za-z0-9\/+=])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=])/)
  amazonKeyMatches.each do |amazonKeyMatch|
    warn("Possible amazon secret key hardcoded found in `#{file}` - `#{amazonKeyMatch}`") if amazonKeyMatch && !rejected_files.include?(file)
  end
end

########################
#      iOS FUNCTIONS   #
########################

def checkAtsExceptions(file)
  # Warn that ATS Exception is set in plist
  atsExceptionMatches = checkForRegex(file, /\+.*NSAppTransportSecurity/)
  atsExceptionMatches.each do |atsExceptionMatch|
    warn("ATS Exception found in plist `#{file}`") if atsExceptionMatch
  end
end

def checkLandscapeOrientation(file)
  # Warn that Landscape orientation is set in plist
  landscapeMatches = checkForRegex(file, /\+.*UIInterfaceOrientationLandscape/)
  landscapeMatches.each do |landscapeMatch|
    message("Landscape orientation is set in plist `#{file}`") if landscapeMatch
  end
end

def checkCakefileMissconfig(file)
  # Warn that some changes can 'break' provisionings and sign certificates configurations
  cakefileMatches = checkForRegex(file, /\+.*(PROVISIONING_PROFILE_SPECIFIER|BUNDLE_ID|DEVELOPMENT_TEAM|CODE_SIGN_IDENTITY)/)
  cakefileMatches.each do |cakefileMatch|
    warn("Lines modified on `Cakefile` can missconfigure project provisionings and sign certificates") if cakefileMatch
  end
end

def validatePodfile(modified_files)
  # Warn if 'Podfile' was modified but 'Podfile.lock' was not
  if modified_files.include?("Podfile")
    if !modified_files.include?("Podfile.lock")
      warn("`Podfile` was modified but `Podfile.lock` was not")
    else
      warn("`Podfile` was modified")
    end
    begin
      checkExternalPods("Podfile")
      checkPodWithoutVersion("Podfile")
    rescue
      exceptionMessages(file)
    end
  end
end

def checkExternalPods(file)
  # Warn pods being loaded from external git repos
  podExternalMatches = checkForRegex(file, /\+.*:git/)
  podExternalMatches.each do |podExternalMatch|
    message("`Podfile` has pods being loaded from external git repos at `#{podExternalMatch}`") if podExternalMatch
  end
end

def checkPodWithoutVersion(file)
  # Warn when no version is specified
  podNoVersionMatches = checkForRegex(file, /\+.*pod\s*'[a-zA-Z0-9-]*'(?!,)/)
  podNoVersionMatches.each do |podNoVersionMatch|
    warn("No version specified for pod at `#{podNoVersionMatch}`") if podNoVersionMatch
  end
end

def validatePlistFiles(modified_files)
  check_next_line = false
  plist_files_paths = modified_files.select { |path| path.include?("Supporting") && path =~ /.*Info\.plist$/ }

  plist_files_paths.each do |file|
    begin
      checkAtsExceptions(file)
      checkLandscapeOrientation(file)

      File.foreach(file) do |line|
        line = line.gsub('\n','').strip
        # Warn Facebook ID hardcoded
        if check_next_line
          warn("Facebook App ID is hardcoded in plist `#{file}`") if line =~ /\+.*<string>\d*<\/string>/
          check_next_line = false
        end
        check_next_line = true if line =~ /FacebookAppID/
      end
    rescue
      exceptionMessages(file)
    end
  end
end

def checkTodo(file)
  # Warn developers things that need to be done
  todoMatches = checkForRegex(file, /\+.*(#\s*|\/\/\s*)(TO\s*DO|TO_DO)/mi)
  todoMatches.each do |todoMatch|
    warn("`TODO` was added in `#{file}`") if todoMatch
  end
end

def validateSwiftFiles(file)
  File.foreach(file) do |line|
    line = line.gsub('\n','').strip
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
end

def checkHardcodedNib(file)
  File.foreach(file) do |line|
    line = line.gsub('\n','').strip
    ext = File.extname(file)
    case ext
    when ".xib"
      
      color_white_1                  = "white=\"1\""
      color_white_0                  = "white=\"0\.0\""
      color_gray_arbitrary_1         = "red=\"0\.93725490196078431\" green=\"0\.93725490196078431\" blue=\"0\.95686274509803926\" alpha=\"1\""
      color_gray_arbitrary_2         = "red=\"0\.93725490199999995\" green=\"0\.93725490199999995\" blue=\"0\.95686274510000002\" alpha=\"1\""
      color_black                    = "red=\"0\.0\" green=\"0\.0\" blue=\"0\.0\""
      color_white_2                  = "red=\"1\" green=\"1\" blue=\"1\" alpha=\"1\""
      attr_text_color                = "key=\"textColor\" cocoaTouchSystemColor=\"darkTextColor\"\/>"
      attr_title_shadow_color        = "key=\"titleShadowColor\""
      cocoa_touch_system_color       = "cocoaTouchSystemColor"
      tag_nil                        = "<nil"
      tag_view                       = "<view"
      user_defined_runtime_attribute = "userDefinedRuntimeAttribute"
      tag_string                     = "<string key=\"text\""
      image                          = "image"
      tag_string_empty               = "<\/string>"
      tag_label                      = "<label"
      tag_document                   = "<document"

      # Warning hardcoded colors on nib files
      if line =~ /
        <color(?!.*(?:#{Regexp.quote(color_white_1)}
        | #{Regexp.quote(color_white_0)}
        | #{Regexp.quote(color_gray_arbitrary_1)}
        | #{Regexp.quote(color_gray_arbitrary_2)}
        | #{Regexp.quote(color_black)}
        | #{Regexp.quote(color_white_2)}
        | #{Regexp.quote(attr_text_color)}
        | #{Regexp.quote(attr_title_shadow_color)}
        | #{Regexp.quote(cocoa_touch_system_color)}
        | #{Regexp.quote(tag_nil)}
        | #{Regexp.quote(tag_view)}
        | #{Regexp.quote(user_defined_runtime_attribute)}
        | #{Regexp.quote(tag_string)}
        | #{Regexp.quote(image)}
        | #{Regexp.quote(tag_string_empty)}
        | #{Regexp.quote(tag_label)}
        | #{Regexp.quote(tag_document)})).*\/>
        /x
        warn("Possible hardcoded color found in `#{file}` at `#{line}`")
      end
      # Warning hardcoded fonts on nib files
      if line =~ /<fontDescription(?!.*(?:key="fontDescription" type="system"|adjustsFontSizeToFit="NO"|minimumFontSize=|<\/customFonts>|<customFonts key="customFonts">)).*/
        warn("Possible hardcoded font found in `#{file}` at `#{line}`")
      end
      # Warning forbidden words on nib files
      if line =~ /exclude|misplaced/
        warn("The file: `#{file}` contains some suspicious keywords like `misplaced` or `exclude`")
      end
    end
  end
end

###########################################

# moved files have a pattern that were  messing with file reading
modified_files = git.modified_files.select { |path| !path.include? "=>" }

# Comparing only readable files
modified_files = modified_files.reject { |f|  /.*\.(tgz|png|jpg|gem)/.match(File.extname(f)) }

# Removing deleted files from modified files array
modified_files = modified_files.reject { |f| git.deleted_files.include?(f) }

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
  warn "@#{github.pr_author} Please provide a summary in the Pull Request description"
end

# Common files
files_to_check = ["Gemfile.lock", ".travis.yml", ".gitignore", "Dangerfile"]
# Node files
files_to_check += ["yarn.lock", "docker-compose.yml", "Procfile", "npm-shrinkwrap.json", "node_modules", "tasks/options/env.coffee", "tslint.json"]
# iOS files
files_to_check += ["Cakefile", "fastlane/settings.yml.erb", "fastlane/Fastfile", "Podfile.lock"]
# Check if files were modified
(modified_files & files_to_check).each do |file|
  message("`#{file}` modified")
end

# Warn if 'Gemfile' was modified and 'Gemfile.lock' was not
if modified_files.include?("Gemfile")
  if !modified_files.include?("Gemfile.lock")
    warn("`Gemfile` was modified but `Gemfile.lock` was not")
  else
    message("`Gemfile` modified")
  end
end

if @platform == "ios"
  validatePodfile(modified_files)
  checkCakefileMissconfig("Cakefile") if modified_files.include?("Cakefile")
  validatePlistFiles(modified_files)
end

validatePackageJson(modified_files, github.pr_diff) if @platform == "nodejs" || @platform == "web"

modified_files.each do |file|
  begin
    checkForFile(file)
  rescue
    exceptionMessages(file)
  end
end
