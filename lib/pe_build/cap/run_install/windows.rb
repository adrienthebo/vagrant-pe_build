require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::Windows

  extend PEBuild::OnMachine

  # Run the PE installer on Windows systems
  #
  # @param machine [Vagrant::Machine] The Vagrant machine on which to run the
  #   installation.
  # @param installer_dir [String] A path to the PE installer.
  # @param answers [Hash[String => String}] A hash of options that will be
  #   passed to msiexec as `key=value` pairs.
  #
  # @param options [Hash] Additional options that influence installer behavior.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers, **options)
    install_options = answers.map{|e| e.join('=')}.join(' ')
    # Lots of PowerShell commands can handle UNIX-style paths. msiexec can't.
    installer_path = installer_path.gsub('/', '\\')

    cmd = <<-EOS
$params = @(
  "/qn",
  "/i `"#{installer_path}`"",
  "/l*v puppet-enterprise-installer.log",
  "#{install_options}"
)

$Result = (Start-Process -FilePath "msiexec.exe" -ArgumentList $params -Wait -Passthru).ExitCode
Write-Host "msiexec completed with exitcode: ${Result}"
exit $Result
EOS

    machine.ui.info "Running: #{cmd}"

    on_machine(machine, cmd)
  end
end
