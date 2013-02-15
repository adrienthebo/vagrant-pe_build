require 'pe_build'
require 'pe_build/provisioners'
require 'vagrant'
require 'fileutils'
require 'erb'

class PEBuild::Provisioners::PuppetEnterpriseBootstrap < Vagrant::Provisioners::Base

  class Config < Vagrant::Config::Base
    attr_writer :verbose, :master, :answers

    def role=(rolename)
      @role = (rolename.is_a?(Symbol)) ? rolename : rolename.intern
    end

    def role
      @role || :agent
    end

    def verbose
      @verbose || true
    end

    def master
      @master || 'master'
    end

    def answers
      # Either the path the user provided to the answers file under
      # the project answers dir, or see if one exists based on the role.
      @answers || "#{role}.txt"
    end

    def validate(env, errors)
      errors.add("role must be one of [:master, :agent]") unless [:master, :agent].include? role
    end
  end

  def self.config_class
    Config
  end

  def initialize(*args)
    super

    load_variables

    @cache_path   = File.join(@env[:root_path], '.pe_build')
    @answers_dir  = File.join(@cache_path, 'answers')
  end

  def validate(app, env)

  end

  def prepare
    FileUtils.mkdir @cache_path unless File.directory? @cache_path
    @env[:action_runner].run(:prep_build, :unpack_directory => @cache_path)
  end

  def provision!
    # determine if bootstrapping is necessary

    prepare_answers_file
    configure_installer

    [:pre, :provision, :post].each do |stepname|
      [:base, config.role].each do |rolename|
        step rolename, stepname
      end
    end
  end

  private

  # I HATE THIS.
  def load_variables
    if @env[:box_name]
      @root     = @env[:vm].pe_build.download_root
      @version  = @env[:vm].pe_build.version
      @filename = @env[:vm].pe_build.version
      @suffix   = @env[:vm].pe_build.suffix
    end

    @root     ||= @env[:global_config].pe_build.download_root
    @version  ||= @env[:global_config].pe_build.version
    @filename ||= @env[:global_config].pe_build.filename
    @suffix   ||= @env[:global_config].pe_build.suffix
  end

  def prepare_answers_file
    @env[:ui].info "Creating answers file, node:#{@env[:vm].name}, role: #{config.role}"
    FileUtils.mkdir_p @answers_dir unless File.directory? @answers_dir
    dest = "#{@answers_dir}/#{@env[:vm].name}.txt"

    # answers dir is enforced
    user_answers = File.join(@env[:root_path],"answers/#{config.answers}")
    if File.exists?(user_answers)
      template = File.read(user_answers)
    else
      @env[:ui].info "Using default answers, no answers file available at #{user_answers}"
      template = File.read("#{PEBuild.source_root}/templates/answers/#{config.role}.txt.erb")
    end

    contents = ERB.new(template).result(binding)

    @env[:ui].info "Writing answers file to #{dest}"
    File.open(dest, "w") do |file|
      file.write contents
    end
  end

  def step(role, stepname)
    script_dir  = File.join(PEBuild.source_root, 'bootstrap', role.to_s, stepname.to_s)
    script_list = Dir.glob("#{script_dir}/*")

    if script_list.empty?
      @env[:ui].info "No steps for #{role}/#{stepname}", :color => :cyan
    end

    script_list.each do |template_path|
      template = File.read(template_path)
      contents = ERB.new(template).result(binding)

      on_remote contents
    end
  end

  # Determine the proper invocation of the PE installer
  #
  # @todo Don't restrict this to the universal installer
  def configure_installer
    vm_base_dir = "/vagrant/.pe_build"
    installer   = "#{vm_base_dir}/puppet-enterprise-#{@version}-#{@suffix}/puppet-enterprise-installer"
    answers     = "#{vm_base_dir}/answers/#{@env[:vm].name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    @installer_cmd = "#{installer} -a #{answers} -l #{log_file}"
  end

  def on_remote(cmd)
    env[:vm].channel.sudo(cmd) do |type, data|
      color = (type == :stdout) ? :green : :red
      @env[:ui].info(data.chomp, :color => color, :prefix => false)
    end
  end
end
