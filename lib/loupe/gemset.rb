class GemsetNotFoundException < Exception
  def initialize(file_path)
    super("'#{file_path}' was not found")
  end
end
class GemsetInvalidFormatException < Exception; end

class Gemset
  include Enumerable
  attr_reader :specs, :file_path

  def initialize(file_path, lazy_specs)
    @file_path = file_path
    @specs = lazy_specs.sort{ |x,y| x.name <=> y.name}
  end

  def each
    @specs.each do |s|
      yield s
    end
  end

    def check_for_unsafe_versions(advisory_repository)
    results = {}
    specs.each do |spec|
      result = advisory_repository.check_for_unsafe_versions(spec)
      next if result.empty?
      results[spec.to_s] = result
    end
    results
  end

  def self.parse_lock_file(file_path)
    raise GemsetNotFoundException.new(file_path) if !File.exist?(file_path)
    with_bundle_gemfile_env(file_path) do
      new(file_path, Bundler::LockfileParser.new(File.read(file_path)).specs)
    end
  end

  def self.parse_gem_file(file_path, resolve_remotely=false)
    raise GemsetNotFoundException.new(file_path) if !File.exist?(file_path)
    gem_file_specs = with_bundle_gemfile_env(file_path) do
      definition = Bundler::Definition.build(file_path, nil, nil)
      resolve_remotely ? definition.resolve_remotely! : definition.resolve_with_cache!
    end
    specs = gem_file_specs.to_a.map { |a| Bundler::LazySpecification.new(a.name, a.version, a.platform)}

    new(file_path, specs)
  end

  #bundler uses this environment variable to locate the root of the application
  #and subsequently any 'vendor/cache' directory.
  #loupe is designed to be run from anywhere so we explicitly set it here
  #so we can do this
  def self.with_bundle_gemfile_env(file_path, &block)
    temp = ENV['BUNDLE_GEMFILE']
    begin
      ENV['BUNDLE_GEMFILE'] = file_path
      block.call
    ensure
      ENV['BUNDLE_GEMFILE'] = temp
    end
  end
end