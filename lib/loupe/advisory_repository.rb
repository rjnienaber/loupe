require 'open3'

class RepositoryDownloadException < Exception; end
class RepositoryUpdateException < Exception; end

class AdvisoryRepository
  def initialize(advisories)
    @gem_advisories = {}
    advisories.each do |a|
      @gem_advisories[a.gem] = [] if @gem_advisories[a.gem].nil?
      @gem_advisories[a.gem] << a
    end
  end

  def [] key
    @gem_advisories[key] || []
  end

  def check_for_unsafe_versions(spec)
    self[spec.name].reject { |a| a.version_safe?(spec)}
  end

  def self.load(cli)
    if git_dir_exists?(cli.git_dir)
      message, exit_code = update_git_dir(cli.git_dir)
      raise RepositoryUpdateException.new(message) if exit_code != 0
    else
      message, exit_code = clone_advisory_repo(cli.advisory_url, cli.git_dir)
      raise RepositoryDownloadException.new(message) if exit_code != 0
    end

    new(advisory_files(cli.git_dir).map { |f| Advisory.load(f)})
  end

  private
  def self.git_dir_exists?(git_advisory_dir)
    File.directory?(git_advisory_dir)
  end

  def self.clone_advisory_repo(advisory_url, git_advisory_dir)
    execute("git clone #{advisory_url} #{git_advisory_dir}")
  end

  def self.update_git_dir(git_advisory_dir)
    execute("cd #{git_advisory_dir}; git pull")
  end

  def self.advisory_files(git_advisory_dir)
    Dir["#{git_advisory_dir}/**/*.yml"]
  end

  def self.execute(command)
    stdin, stdout, stderr, status = Open3.popen3(command)
    message = stdout.gets.to_s + stderr.gets.to_s
    [message, status.value]
  end
end