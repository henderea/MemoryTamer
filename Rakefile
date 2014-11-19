# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue
  system('bundle install')
  exit 1
end

module Motion::Project
  class Builder
    def codesign(config, platform)
      app_bundle   = config.app_bundle_raw('MacOSX')
      entitlements = File.join(config.versionized_build_dir(platform), 'Entitlements.plist')
      if File.mtime(config.project_file) > File.mtime(app_bundle) or !system("/usr/bin/codesign --verify \"#{app_bundle}\" >& /dev/null")
        App.info 'Codesign', app_bundle
        File.open(entitlements, 'w') { |io| io.write(config.entitlements_data) }
        sh "/usr/bin/codesign --deep --force --sign \"#{config.codesign_certificate}\" --entitlements \"#{entitlements}\" \"#{app_bundle}\""
      end
    end
  end
end

Motion::Project::App.setup do |app|
  app.icon                      = 'Icon.icns'
  app.name                      = 'MemoryTamer'
  app.version                   = '1.2.4'
  app.short_version             = '1.2.4'
  app.identifier                = 'us.myepg.MemoryTamerMAS'
  app.info_plist['NSUIElement'] = 1
  app.deployment_target         = '10.8'
  app.codesign_certificate      = '3rd Party Mac Developer Application: Eric Henderson (SKWXXEM822)'
  app.embedded_frameworks << 'vendor/Growl.framework'
  app.vendor_project('vendor/mem_info', :static)
  app.frameworks << 'ServiceManagement'

  app.entitlements['com.apple.security.app-sandbox']    = true
  app.entitlements['com.apple.security.network.client'] = true
  app.category = 'utility'
  app.release do
    app.info_plist['AppStoreRelease'] = true
  end

  app.pods do
    pod 'CocoaLumberjack'
    pod 'HockeySDK-Mac', '~> 2.1'
  end
end

class Motion::Project::App
  class << self
    #
    # The original `build' method can be found here:
    # https://github.com/HipByte/RubyMotion/blob/master/lib/motion/project/app.rb#L75-L77
    #
    alias_method :build_before_copy_helper, :build

    def build(platform, options = {})

      helper_name = 'MTLaunchHelper'

      # First let the normal `build' method perform its work.
      build_before_copy_helper(platform, options)
      # Now the app is built, but not codesigned yet.

      destination = File.join(config.app_bundle(platform), 'Library/LoginItems')
      info 'Create', destination
      FileUtils.mkdir_p destination

      helper_path = File.join("./#{helper_name}", config.versionized_build_dir(platform)[1..-1], "#{helper_name}.app")
      info 'Copy', helper_path
      FileUtils.cp_r helper_path, destination

      system("ruby ./xpc-rename-move.rb './files/' '#{config.app_bundle(platform)}' '#{config.codesign_certificate}'")
    end
  end
end