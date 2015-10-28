# This requires the xcoder gem to be installed
require 'xcoder'

projectname = "Robby"
crashlytics_key = "8c52c89c4204a4e3a71ea26a6e5d2cfc97b02b91"
crashlytics_secret = "c12dfe4dffc9a0f2c191a596d0218c2a3dba7c7c2c5f282eea82d82bcc97be71"

project = Xcode.project("platforms/ios/#{projectname}.xcodeproj")
frameworks = project.frameworks_group


# Cordova Project We only have 1 target = The project name
target=project.targets[0]

# Add the framework as a path
# It assumes that Crashlytics is in the project Dir"
crashlytics = frameworks.create_framework 'name' => 'Crashlytics.framework' , 'path' => 'Crashlytics.framework', 'sourceTree' => '<group>'
target.framework_build_phase do |phase|
  puts 'Adding Crashlytics framework'
  phase.add_build_file crashlytics
end

# Adding Framework search paths to both
['Release', 'Debug'].each do |s|
  puts 'Adding Framework search paths to both configs'
  config = project.target(projectname).config(s)
  config.set("FRAMEWORK_SEARCH_PATHS",[ "$(inherited)","$(PROJECT_DIR)"])
end

# Add the runscript during build
target.create_build_phase :run_script do |script|
  puts 'Adding Crashlytics buildscript'
  script.shell_script = "echo 'sending to Crashlytics'\n" + "./Crashlytics.framework/run #{crashlytics_key} #{crashlytics_secret}\n"
  # For easy debugging
  script.show_env_vars_in_log = 1
end

project.save!