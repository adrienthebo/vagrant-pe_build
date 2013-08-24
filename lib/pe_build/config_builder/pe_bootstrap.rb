require 'config_builder/model'

class PEBuild::ConfigBuilder::PEBootstrap < ::PEBuild::ConfigBuilder::Global

  # @!attribute [rw] role
  #   @return [Symbol] The role of the Puppet Enterprise install.
  def_model_attribute :role

  # @!attribute [rw] verbose
  #   @return [Boolean] Whether or not to show the verbose output of the Puppet
  #     Enterprise install.
  def_model_attribute :verbose

  # @!attribute [rw] master
  #   @return [String] The address of the puppet master.
  def_model_attribute :master

  # @!attribute [rw] answer_file
  #   @return [String] The location of alternate answer file for PE
  #     installation. Values can be paths relative to the Vagrantfile's project
  #     directory.
  def_model_attribute :answer_file

  # @!attribute [rw] relocate_manifests
  #   @return [Boolean] Whether or not to change the PE master to use a config
  #     of manifestdir=/manifests and modulepath=/modules. This is meant to be
  #     used when the vagrant working directory manifests and modules are
  #     remounted on the guest.
  def_model_attribute :relocate_manifests

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_bootstrap do |pe|
        # Globally settable attributes
        pe.download_root = attr(:download_root) if attr(:download_root)
        pe.version       = attr(:version)       if attr(:version)
        pe.suffix        = attr(:suffix)        if attr(:suffix)
        pe.filename      = attr(:filename)      if attr(:filename)

        pe.role               = attr(:role)               if attr(:role)
        pe.verbose            = attr(:verbose)            if attr(:verbose)
        pe.master             = attr(:master)             if attr(:master)
        pe.answer_file        = attr(:answer_file)        if attr(:answer_file)
        pe.relocate_manifests = attr(:relocate_manifests) if attr(:relocate_manifests)
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_bootstrap', self)
end
