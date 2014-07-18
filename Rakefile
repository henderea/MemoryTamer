# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
# ignored
end

Motion::Project::App.setup do |app|
  app.icon                           = 'Icon.icns'
  app.info_plist['CFBundleIconFile'] = 'Icon.icns'
  app.name                           = 'MemoryTamer'
  app.version                        = '0.4'
  app.identifier                     = 'us.myepg.MemoryTamer'
  app.info_plist['NSUIElement']      = 1
  app.deployment_target              = '10.7'
  app.codesign_certificate           = 'Developer ID Application: Eric Henderson (SKWXXEM822)'
end
