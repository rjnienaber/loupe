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
    new(file_path, Bundler::LockfileParser.new(File.read(file_path)).specs)
  end

  def self.parse_gem_file(file_path, resolve_remotely=false)
    raise GemsetNotFoundException.new(file_path) if !File.exist?(file_path)
    definition = Bundler::Definition.build(file_path, nil, nil)

    gem_file_specs = resolve_remotely ? definition.resolve_remotely! : definition.resolve_with_cache!
    specs = gem_file_specs.to_a.map { |a| Bundler::LazySpecification.new(a.name, a.version, a.platform)}

    new(file_path, specs)
  end
end