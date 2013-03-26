class GemsetNotFoundException < Exception; end
class GemsetInvalidFormatException < Exception; end

class Gemset
  include Enumerable
  attr_reader :specs

  def initialize(lazy_specs)
    @specs = lazy_specs
  end

  def each
    @specs.each do |s|
      yield s
    end
  end

  def self.parse_lock_file(file_path)
    raise GemsetNotFoundException.new(file_path) if !File.exist?(file_path)
    new(Bundler::LockfileParser.new(File.read(file_path)).specs)
  end

  def self.parse_gem_file(file_path)
    raise GemsetNotFoundException.new(file_path) if !File.exist?(file_path)
    definition = Bundler::Definition.build(file_path, nil, nil)

    gem_file_specs = definition.resolve_remotely!
    specs = gem_file_specs.to_a.map { |a| Bundler::LazySpecification.new(a.name, a.version, a.platform)}
    specs.sort!{ |x,y| x.name <=> y.name}

    new(specs)
  end
end