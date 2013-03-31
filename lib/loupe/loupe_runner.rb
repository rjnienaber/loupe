class LoupeRunner
  attr_reader :cli

  NO_VULNERABILITIES_FOUND = 0
  VULNERABILITIES_FOUND = 1
  INVALID_CLI = 2
  UNEXPECTED_ERROR = 3

  def initialize(cli)
    @cli = cli
  end

  def advisory_repo
    @advisory_repository ||= AdvisoryRepository.load(cli)
  end

  def run
    return INVALID_CLI if !cli.valid?

    results = cli.lock_files.map do |f|
      process_gemset(f, Gemset.parse_lock_file(f))
    end

    results += cli.gem_files.each do |f|
      process_gemset(f, Gemset.parse_gem_file(f))
    end

    results.all? ? NO_VULNERABILITIES_FOUND : VULNERABILITIES_FOUND
  rescue Exception => e
    print_message("Unexpected error: #{e}")
    UNEXPECTED_ERROR
  end

  def process_gemset(file_path, gemset)
    results = gemset.check_for_unsafe_versions(advisory_repo)
    message = cli.formatter.format(file_path, results)
    print_message(message)
    results.empty?
  end

  def print_message(message)
    puts message
  end
end