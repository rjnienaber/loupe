require 'slop'

class Cli
  attr_reader :options, :gem_files, :lock_files, :show_advisory_db_sha, :git_dir, :advisory_url, :resolve_remotely, :formatter, :help

  def initialize(arguments=ARGV)
    begin
      @options = Slop.parse(arguments, :strict => true) do
        on 'g=', 'gemfile=', 'A Gemfile to inspect (can be an array separated by commas)', :as => Array
        on 'l=', 'lockfile=', 'A Gemfile.lock to inspect (can be an array separated by commas)', :as => Array
        on 'r=', 'repo-location=', 'The directory to store the advisory repository', :default => '/var/tmp/loupe_advisories'
        on 'u=', 'repo-url=', 'The url of the github repository that contains advisories', :default => 'https://github.com/rubysec/ruby-advisory-db.git'
        on 's', 'advisory-db-sha', 'Show Advisory Database SHA'
        on 'd', 'resolve-remotely', 'Resolve dependencies by getting latest specs from rubygems', :default => false
        on 'h', 'help', 'Print out this help'
      end
    rescue Slop::InvalidOptionError
      @lock_files = @gem_files = []
      @git_dir = @advisory_url = ''
      @has_valid_parameters = false
      @help = true
      return
    end

    @formatter = ConsoleFormatter.new

    @lock_files = @options[:lockfile] || []

    if @options[:gemfile]
      @gem_files = @options[:gemfile]
    else
      @gem_files = @lock_files == [] ? ['./Gemfile'] : []
    end

    @git_dir = @options[:'repo-location']
    @advisory_url = @options[:'repo-url']
    @resolve_remotely = @options[:'resolve-remotely']
    @show_advisory_db_sha = @options[:'advisory-db-sha']
    @has_valid_parameters = true
    @help = options[:help]
  end

  def valid?
    @has_valid_parameters
  end
end
