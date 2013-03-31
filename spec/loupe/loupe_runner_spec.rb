require 'spec_helper'

describe LoupeRunner do
  let(:cli) { double('cli')}
  let(:advisory_repo) { double('advisory_repo')}
  subject { LoupeRunner.new(cli) }

  before do
    subject.stub(:advisory_repo).and_return(advisory_repo)
  end

  context '#run' do
    it "exits with '2' if invalid parameters assigned" do
      cli.should_receive(:valid?).and_return(false)
      subject.run.should == 2
    end

    it "exits with '3' if there's an unexpected error" do
      cli.should_receive(:valid?).and_return(true)
      cli.should_receive(:lock_files).and_return(['Gemfile.lock'])
      Gemset.should_receive(:parse_lock_file).with('Gemfile.lock').and_raise(Exception.new('Failed to load repo'))

      subject.should_receive(:print_message).with('Unexpected error: Failed to load repo')

      subject.run.should == 3
    end

    it "exits with '4' and outputs vulnerabilities if found" do
      cli.should_receive(:valid?).and_return(true)
      cli.should_receive(:lock_files).and_return(['Gemfile.lock'])
      cli.should_receive(:gem_files).and_return([])

      gemset = double('gemset')
      Gemset.should_receive(:parse_lock_file).with('Gemfile.lock').and_return(gemset)

      subject.should_receive(:process_gemset).with('Gemfile.lock', gemset).and_return(false)

      subject.run.should == 1
    end

    it "exits with '4' and processes multiple files with vulnerabilities" do
      cli.should_receive(:valid?).and_return(true)
      cli.should_receive(:lock_files).and_return(['Gemfile.lock'])
      cli.should_receive(:gem_files).and_return(['Gemfile'])

      gemset = double('gemset')
      Gemset.should_receive(:parse_lock_file).with('Gemfile.lock').and_return(gemset)
      subject.should_receive(:process_gemset).with('Gemfile.lock', gemset).and_return(false)

      gemset_2 = double('gemset_2')
      Gemset.should_receive(:parse_gem_file).with('Gemfile').and_return(gemset_2)
      subject.should_receive(:process_gemset).with('Gemfile', gemset_2).and_return(true)

      subject.run.should == 1
    end

    it "exits with '0' if there are no errors on a Gemfile.lock file" do
      cli.should_receive(:valid?).and_return(true)
      cli.should_receive(:lock_files).and_return(['Gemfile.lock'])
      cli.should_receive(:gem_files).and_return([])

      gemset = double('gemset')
      Gemset.should_receive(:parse_lock_file).with('Gemfile.lock').and_return(gemset)
      subject.should_receive(:process_gemset).with('Gemfile.lock', gemset).and_return(true)

      subject.run.should == 0
    end

    it "exits with '0' if there are no errors on a Gemfile" do
      cli.should_receive(:valid?).and_return(true)
      cli.should_receive(:lock_files).and_return([])
      cli.should_receive(:gem_files).and_return(['Gemfile'])

      gemset = double('gemset')
      Gemset.should_receive(:parse_gem_file).with('Gemfile').and_return(gemset)
      subject.should_receive(:process_gemset).with('Gemfile', gemset).and_return(true)

      subject.run.should == 0
    end
  end

  context '#process_gemset' do
    let(:formatter) { double('formatter')}
    let(:gemset) { double('gemset')}
    before do
      cli.should_receive(:formatter).and_return(formatter)
    end

    it 'returns false if vulnerabilities are found' do
      vulnerabilities = {'RedCloth (4.2.9)' => {'cve' => '2349-3563'}}
      gemset.should_receive(:check_for_unsafe_versions).with(advisory_repo).and_return(vulnerabilities)
      formatter.should_receive(:format).with('Gemfile.lock', vulnerabilities).and_return('formatted message')
      subject.should_receive(:print_message).with('formatted message')

      subject.process_gemset('Gemfile.lock', gemset).should be_false
    end

    it 'returns true if no vulnerabilities are found' do
      gemset.should_receive(:check_for_unsafe_versions).with(advisory_repo).and_return({})
      formatter.should_receive(:format).with('Gemfile.lock', {}).and_return('formatted message')
      subject.should_receive(:print_message).with('formatted message')

      subject.process_gemset('Gemfile.lock', gemset).should be_true
    end
  end
end