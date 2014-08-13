# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
# ignored
end

SKIP_CODESIGN_TIMESTAMP = true

module Motion::Project
  class Builder
    def codesign(config, platform)
      app_bundle   = config.app_bundle_raw('MacOSX')
      entitlements = File.join(config.versionized_build_dir(platform), 'Entitlements.plist')
      if File.mtime(config.project_file) > File.mtime(app_bundle) or !system("/usr/bin/codesign --verify \"#{app_bundle}\" >& /dev/null")
        App.info 'Codesign', app_bundle
        File.open(entitlements, 'w') { |io| io.write(config.entitlements_data) }
        sh "/usr/bin/codesign --deep --force --sign \"#{config.codesign_certificate}\"#{SKIP_CODESIGN_TIMESTAMP ? ' --timestamp=none' : ''} --entitlements \"#{entitlements}\" \"#{app_bundle}\""
      end
    end
  end
end

class MotionHeader
  def include_path
    @prefix
  end
end

Motion::Project::App.setup do |app|
  app.icon                           = 'Icon.icns'
  app.info_plist['CFBundleIconFile'] = 'Icon.icns'
  app.name                           = 'MemoryTamer'
  app.version                        = '0.9.6.1'
  app.short_version                  = '0.9.6.1'
  app.identifier                     = 'us.myepg.MemoryTamer'
  app.info_plist['NSUIElement']      = 1
  app.info_plist['SUFeedURL']        = 'https://raw.githubusercontent.com/henderea/MemoryTamer/master/appcast.xml'
  app.deployment_target              = '10.7'
  app.codesign_certificate           = 'Developer ID Application: Eric Henderson (SKWXXEM822)'
  app.embedded_frameworks << 'vendor/Growl.framework'
  app.embedded_frameworks << 'vendor/Sparkle.framework'
  app.embedded_frameworks << 'vendor/Paddle.framework'
  app.vendor_project('vendor/mem_info', :static)
  # app.include 'sysctl.h', prefix: '/usr/include/sys/'
  # app.include 'vm.h', prefix: '/usr/include/sys/'
end
