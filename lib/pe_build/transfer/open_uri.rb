require 'pe_build/version'
require 'pe_build/idempotent'

require 'open-uri'
require 'progressbar'

class PEBuild::Transfer::OpenURI

  class DownloadFailed < Vagrant::Errors::VagrantError
    error_key(:download_failed, 'pebuild.transfer.open_uri')
  end

  # @param uri [URI]    The http(s) URI to the file to copy
  # @param dst [String] The path to destination of the copied file
  def initialize(uri, dst)
    @uri, @dst = uri, dst

    @logger = Log4r::Logger.new('vagrant::pe_build::transfer::open_uri')
  end

  include PEBuild::Idempotent

  def copy
    idempotent(@dst) do
      tmpfile = download_file
      FileUtils.mv(tmpfile, @dst)
    end
  rescue ::OpenURI::HTTPError, ::OpenSSL::SSL::SSLError, ::SocketError => e
    raise DownloadFailed, :uri => @uri, :msg => e.message
  end

  HEADERS = {'User-Agent' => "Vagrant/PEBuild (v#{PEBuild::VERSION})"}

  private

  # Open a open-uri file handle for the given URL
  #
  # @return [IO]
  def download_file
    progress = nil

    content_length_proc = lambda do |length|
      if length and length > 0
        progress = ProgressBar.new('Fetching file', length)
        progress.file_transfer_mode
      end
    end

    progress_proc = lambda do |size|
      progress.set(size) if progress
    end

    options = HEADERS.merge({
      :content_length_proc => content_length_proc,
      :progress_proc       => progress_proc,
    })

    @logger.info "Fetching file from #{@uri}"

    @uri.open(options)
  end
end
