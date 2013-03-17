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

  def check_unsafe_versions(spec)
    self[spec.name].reject { |a| a.version_safe?(spec)}
  end

  def self.load(cli)
    if git_dir_exists?(cli.git_dir)
      begin
        update_git_dir(cli.git_dir)
      rescue Exception => e
        raise RepositoryUpdateException.new(e.message)
      end
    else
      begin
        clone_advisory_repo(cli.advisory_url, cli.git_dir)
      rescue Exception => e
        raise RepositoryDownloadException.new(e.message)
      end
    end

    new(advisory_files(cli.git_dir).map { |f| Advisory.load(f)})
  end

  private
  def self.git_dir_exists?(git_advisory_dir)
    File.directory?(git_advisory_dir)
  end

  def self.clone_advisory_repo(advisory_url, git_advisory_dir)
    `git clone #{advisory_url} #{git_advisory_dir}`
  end

  def self.update_git_dir(git_advisory_dir)
    `cd #{git_advisory_dir}; git pull`
  end

  def self.advisory_files(git_advisory_dir)
    Dir["#{git_advisory_dir}/**/*.yml"]
  end
end