class Advisory
  attr_reader :gem, :cve, :url, :title, :description, :unaffected_versions, :patched_versions

  def initialize(data)
    @data = data
    @gem = data['gem']
    @cve = data['cve']
    @url = data['url']
    @title = data['title']
    @description = data['description']
    @unaffected_versions = data['unaffected_versions'] || []
    @patched_versions = data['patched_versions']
  end

  def version_safe?(spec)
    return true if unaffected(spec)
    patched(spec)
  end

  def self.load(file_path)
    new(YAML.load(File.read(file_path)))
  end

  private
  def unaffected(spec)
    unaffected_versions.any? do |v|
      if (range = v.split(',')).length == 2
        versions = range.map {|r| Gem::Dependency.new(gem, r)}
        spec.satisfies?(versions[0]) && spec.satisfies?(versions[1])
      else
        spec.satisfies?(Gem::Dependency.new(gem, v))
      end
    end
  end

  def patched(spec)
    patched_versions.map { |v| Gem::Dependency.new(gem, v)}.any? { |v| spec.satisfies?(v)}
  end
end