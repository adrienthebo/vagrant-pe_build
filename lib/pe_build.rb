require 'vagrant'

module PEBuild

  # XXX should be vagrant_home
  def self.archive_directory
    File.expand_path(File.join(ENV['HOME'], '.vagrant.d', 'pe_builds'))
  end

  def self.source_root
    File.expand_path('..', File.dirname(__FILE__))
  end

  def self.template_dir
    File.expand_path('templates', source_root)
  end
end

# I18n to load the en locale
I18n.load_path << File.expand_path("locales/en.yml", PEBuild.template_dir)

require 'pe_build/plugin'
require 'pe_build/version'
