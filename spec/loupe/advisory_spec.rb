require 'spec_helper'

EXAMPLE_2012_3424 = File.expand_path('2012-3424.yml', EXAMPLES_DIR)
EXAMPLE_2012_3465 = File.expand_path('2012-3465.yml', EXAMPLES_DIR)

describe Advisory do
  let(:example) { EXAMPLE_2012_3424 }
  subject { Advisory.load(example)}

  describe "#load 2012-3424.yml" do
    its(:gem) { should == 'actionpack'}
    its(:cve) { should == '2012-3424'}
    its(:url) { should == 'http://www.osvdb.org/show/osvdb/84243'}
    its(:title) { should == 'Ruby on Rails actionpack/lib/action_controller/metal/http_authentication.rb with_http_digest Helper Method Remote DoS'}
    its(:description) { should == 'Ruby on Rails contains a flaw that may allow a remote denial of service.
The issue is triggered when an error occurs in
actionpack/lib/action_controller/metal/http_authentication.rb when the
with_http_digest helper method is being used. This may allow a remote
attacker to cause a loss of availability for the program.
'}
    its(:unaffected_versions) { should == ['>= 2.3.5, <= 2.3.14'] }
    its(:patched_versions) { should == ['~> 3.0.16', '~> 3.1.7', '>= 3.2.7'] }
  end

  describe "#load 2012-3465.yml" do
    let(:example) { EXAMPLE_2012_3465 }
    its(:unaffected_versions) { should == [] }
  end

  describe '#version_safe?' do
    context 'passes' do
      it 'starting unaffected version' do
        spec = Bundler::LazySpecification.new('actionpack', '2.3.5', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'an unaffected version in middle' do
        spec = Bundler::LazySpecification.new('actionpack', '2.3.10', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'ending unaffected version' do
        spec = Bundler::LazySpecification.new('actionpack', '2.3.14', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'patched versions' do
        spec = Bundler::LazySpecification.new('actionpack', '3.0.16', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'patched versions 2' do
        spec = Bundler::LazySpecification.new('actionpack', '3.1.7', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'patched versions 3' do
        spec = Bundler::LazySpecification.new('actionpack', '3.2.7', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'minor version' do
        spec = Bundler::LazySpecification.new('actionpack', '3.3.0', nil)
        subject.version_safe?(spec).should be_true
      end

      it 'major version' do
        spec = Bundler::LazySpecification.new('actionpack', '4.0.0', nil)
        subject.version_safe?(spec).should be_true
      end
    end

    context 'fails' do
      it 'a major version' do
        spec = Bundler::LazySpecification.new('actionpack', '2.0.0', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'a minor version' do
        spec = Bundler::LazySpecification.new('actionpack', '2.2.2', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'the patched version before unaffected versions' do
        spec = Bundler::LazySpecification.new('actionpack', '2.3.4', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'the patched version after unaffected versions' do
        spec = Bundler::LazySpecification.new('actionpack', '2.3.15', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'patched minor versions' do
        spec = Bundler::LazySpecification.new('actionpack', '3.0.15', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'patched minor versions 2' do
        spec = Bundler::LazySpecification.new('actionpack', '3.1.6', nil)
        subject.version_safe?(spec).should be_false
      end

      it 'patched minor versions 3' do
        spec = Bundler::LazySpecification.new('actionpack', '3.2.6', nil)
        subject.version_safe?(spec).should be_false
      end
    end
  end
end