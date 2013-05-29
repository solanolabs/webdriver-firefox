# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'webdriver-firefox/version'

class Config
  class << self
    def files
      fnames = `git ls-files -- bin/* lib/*`.split("\n")
      return fnames
    end

    def executables
      fnames = `git ls-files -- bin/*`.split("\n")
      fnames = fnames.map { |f| File.basename(f) }
      return fnames
    end
  end
end

Gem::Specification.new do |s|
  s.name        = "webdriver-firefox"
  s.version     = WebdriverFirefox::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Solano Labs"]
  s.email       = ["info@tddium.com"]
  s.homepage    = "http://www.solanolabs.com/"
  s.summary     = %q{WebdriverFirefox}
  s.description = %q{Lockless Support for Webdriver and Firefox}
  
  s.rubyforge_project = "tddium"

  s.files         = Config.files
  s.extensions    = []
  s.test_files    = []
  s.executables   = Config.executables
  s.require_paths = ["lib"]

  s.add_dependency("selenium-webdriver")
end
