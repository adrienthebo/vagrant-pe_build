require 'vagrant'

require 'pe_build/config/global'
require 'pe_build/config_default'

module PEBuild
module Config

class PEBootstrap < PEBuild::Config::Global

  # @!attribute master
  #   @return The DNS hostname of the Puppet master for this node.
  attr_accessor :master

  # @!attribute answer_file
  #   @return [String] The path to a user specified answer_file file (Optional)
  attr_accessor :answer_file

  # @!attribute verbose
  #   @return [TrueClass, FalseClass] if stdout will be displayed when installing
  attr_accessor :verbose

  # @!attribute role
  #   @return [Symbol] The type of the PE installation role. One of [:master, :agent]
  attr_accessor :role
  VALID_ROLES = [:agent, :master]

  # @!attribute step
  #   @return [Hash<Symbol, String>] a hash whose keys are step levels, and whose
  #                                  keys are directories to optional steps.
  attr_accessor :step

  attr_accessor :relocate_manifests
  # @!attribute relocate_manifests
  #   @return [TrueClass, FalseClass] if the puppet master should use manifests
  #                                   out of the vagrant directory.

  # @todo config option for autosigning.
  #attr_accessor :autosign

  def initialize
    super
    @role        = UNSET_VALUE
    @verbose     = UNSET_VALUE
    @master      = UNSET_VALUE
    @answer_file = UNSET_VALUE

    @relocate_manifests = UNSET_VALUE

    #@autosign    = UNSET_VALUE

    @step    = {}
  end

  include PEBuild::ConfigDefault

  def finalize!
    set_default :@role,        :agent
    set_default :@verbose,     true
    set_default :@master,      'master'
    set_default :@answer_file, nil

    set_default :@relocate_manifests, (@role == :master)
  end

  def add_step(name, script_path)
    name = (name.is_a?(Symbol)) ? name : name.intern
    step[name] = script_path
  end

  # @todo Convert error strings to I18n
  def validate(machine)
    h = super

    errors = []
    if @version == UNSET_VALUE and machine.config.pe_build.version == UNSET_VALUE
      errors << "Version must be set on provisioner when unset globally"
    end

    unless VALID_ROLES.any? {|sym| @role == sym}
      errors << "Role must be one of #{VALID_ROLES.inspect}, was #{@role.inspect}"
    end

    unless @verbose == !!@verbose
      errors << "Verbose must be a boolean, got #{@verbose.class}"
    end

    unless @master.is_a? String
      errors << "Master must be a string, got a #{@master.class}"
    end

    if @answer_file and !File.readable? @answer_file
      errors << "Answers must be a readable file if given"
    end

    if @relocate_manifests and not @role == :master
      errors << "'relocate_manifests' can only be applied to a master"
    end

    errors |= h.values.flatten
    {"PE Bootstrap" => errors}
  end
end
end
end
