require 'spec_helper'


describe Gemset do
  let(:example_specs) { specs = [["rake", "10.0.3"], ["RedCloth", "4.2.9"], ["i18n", "0.6.1"], ["multi_json", "1.7.1"], ["activesupport", "3.2.13"], ["builder", "3.0.4"], ["activemodel", "3.2.13"], ["erubis", "2.7.0"], ["journey", "1.0.4"], ["rack", "1.4.5"], ["rack-cache", "1.2"], ["rack-test", "0.6.2"], ["hike", "1.2.1"], ["tilt", "1.3.6"], ["sprockets", "2.2.2"], ["actionpack", "3.2.13"], ["mime-types", "1.21"], ["polyglot", "0.3.3"], ["treetop", "1.4.12"], ["mail", "2.5.3"], ["actionmailer", "3.2.13"], ["arel", "3.0.2"], ["tzinfo", "0.3.37"], ["activerecord", "3.2.13"], ["activeresource", "3.2.13"], ["acts_as_list", "0.2.0"], ["acts_as_tree_rails3", "0.1.0"], ["addressable", "2.3.3"], ["akismet", "1.0.0"], ["bluecloth", "2.2.0"], ["bundler", "1.3.2"], ["carrierwave", "0.8.0"], ["coderay", "1.0.9"], ["daemons", "1.1.9"], ["diff-lcs", "1.1.3"], ["dynamic_form", "1.1.4"], ["eventmachine", "1.0.3"], ["excon", "0.20.1"], ["factory_girl", "3.6.2"], ["flickraw", "0.9.6"], ["flickraw-cached", "20120701"], ["formatador", "0.2.4"], ["net-ssh", "2.6.6"], ["net-scp", "1.1.0"], ["nokogiri", "1.5.8"], ["ruby-hmac", "0.4.0"], ["fog", "1.10.0"], ["htmlentities", "4.3.1"], ["json", "1.7.7"], ["kaminari", "0.14.1"], ["method_source", "0.8.1"], ["subexec", "0.0.4"], ["mini_magick", "1.3.3"], ["rack-ssl", "1.3.3"], ["rdoc", "3.12.2"], ["thor", "0.17.0"], ["railties", "3.2.13"], ["rails", "3.2.13"], ["prototype-rails", "3.2.1"], ["slop", "3.4.4"], ["pry", "0.9.12"], ["pry-rails", "0.2.2"], ["rails_autolink", "1.0.9"], ["recaptcha", "0.3.5"], ["require_relative", "1.0.3"], ["rspec-core", "2.12.2"], ["rspec-expectations", "2.12.1"], ["rspec-mocks", "2.12.2"], ["rspec-rails", "2.12.2"], ["rubypants", "0.2.0"], ["simplecov-html", "0.7.1"], ["simplecov", "0.7.1"], ["thin", "1.5.1"], ["uuidtools", "2.1.3"], ["webrat", "0.7.3"]]  }

  describe '#parse_lock_file' do
    it 'returns all specs' do
      file_path = File.expand_path('Gemfile.lock', EXAMPLES_DIR)
      gemset = Gemset.parse_lock_file(file_path)

      gemset.file_path.should == file_path

      gemset.specs.all? { |s| s.kind_of?(Bundler::LazySpecification)}.should be_true

      gemset.specs[0].name.should == 'addressable'
      gemset.specs[0].version.to_s.should == '2.3.2'

      gemset.specs[-1].name.should == 'yajl-ruby'
      gemset.specs[-1].version.to_s.should == '1.1.0'
    end

    it "throws an error if the file doesn't exist" do
      expect { Gemset.parse_lock_file('non-existent-fail.txt') }.to raise_error(GemsetNotFoundException, "'non-existent-fail.txt' was not found")
    end
  end

  describe '#parse_gem_file' do
    it 'returns all specs' do
      #remotely resolved specset
      spec_set = Bundler::SpecSet.new(example_specs.map {|s| Gem::Specification.new(s[0], s[1])})
      Bundler::Definition.any_instance.stub(:resolve_remotely!).and_return(spec_set)

      file_path = File.expand_path('Gemfile_2', EXAMPLES_DIR)
      gemset = Gemset.parse_gem_file(file_path)

      gemset.file_path.should == file_path

      gemset.specs.all? { |s| s.kind_of?(Bundler::LazySpecification)}.should be_true
      gemset.specs[0].name.should == 'RedCloth'
      gemset.specs[0].version.to_s.should == '4.2.9'

      gemset.specs[-1].name.should == 'webrat'
      gemset.specs[-1].version.to_s.should == '0.7.3'
    end

    it "throws an error if the file doesn't exist" do
      expect { Gemset.parse_gem_file('non-existent-fail.txt') }.to raise_error(GemsetNotFoundException, "'non-existent-fail.txt' was not found")
    end
  end

  context '#check_for_unsafe_versions' do
    let(:specs) { example_specs[0..2].map{ |s| Bundler::LazySpecification.new(s[0], s[1], nil)} }
    subject { Gemset.new(nil, specs) }

    it 'returns empty hash when no vulnerabilities are found' do
      advisory_repo = double('advisory_repo')
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'rake'}.and_return([])
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'RedCloth'}.and_return([])
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'i18n'}.and_return([])

      subject.check_for_unsafe_versions(advisory_repo).should == {}
    end

    it 'returns hash with found vulnerabilities' do
      advisory_repo = double('advisory_repo')
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'rake'}.and_return([])
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'RedCloth'}.and_return('cve' => '2349-3563')
      advisory_repo.should_receive(:check_for_unsafe_versions).with { |s| s.name == 'i18n'}.and_return([])

      subject.check_for_unsafe_versions(advisory_repo).should == {'RedCloth (4.2.9)' => {'cve' => '2349-3563'}}
    end
  end

  context 'implements Enumerable' do
    let(:specs) { example_specs[0..2].map{ |s| Bundler::LazySpecification.new(s[0], s[1], nil)} }
    subject { Gemset.new(nil, specs) }
    it '#each' do
      subject.each_with_index do |s, i|
        case i
          when 0 then s.name.should == 'RedCloth'
          when 1 then s.name.should == 'i18n'
          when 2 then s.name.should == 'rake'
        end
      end
    end

    it '#map' do
      mapped_specs = subject.map { |s| s.name }
      mapped_specs[0].should == 'RedCloth'
      mapped_specs[1].should == 'i18n'
      mapped_specs[2].should == 'rake'
    end
  end
end