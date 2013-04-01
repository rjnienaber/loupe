require 'spec_helper'

describe AdvisoryRepository do
  let(:mock_advisories) do
    advisories = [double('actionpack_1'), double('activerecord_1'), double('actionpack_2')]
    advisories[0].stub(:gem).and_return('actionpack')
    advisories[1].stub(:gem).and_return('activerecord')
    advisories[2].stub(:gem).and_return('actionpack')
    advisories
  end
  subject { AdvisoryRepository.new(mock_advisories)}

  context '#[]' do
    it 'returns gem advisory' do
      advisories = subject['activerecord']
      advisories.length.should == 1
      advisories[0] == mock_advisories[1]
    end

    it 'groups advisories by gem' do
      advisories = subject['actionpack']
      advisories.length.should == 2
      advisories[0] == mock_advisories[0]
      advisories[1] == mock_advisories[2]
    end

    it 'returns empty array when gem not found' do
      subject['unknown'].should == []
    end
  end

  context '#check_for_unsafe_versions' do
    it 'returns empty array if no advisories found' do
      spec = Bundler::LazySpecification.new('unknown', '2.3.5', nil)
      subject.check_for_unsafe_versions(spec).should == []
    end

    it 'returns empty array if no vulnerable versions found' do
      mock_advisories[0].should_receive(:version_safe?).and_return(true)
      mock_advisories[2].should_receive(:version_safe?).and_return(true)

      spec = Bundler::LazySpecification.new('actionpack', '2.3.5', nil)
      subject.check_for_unsafe_versions(spec).should == []
    end

    it 'returns advisory for vulnerable version' do
      mock_advisories[0].should_receive(:version_safe?).and_return(true)
      mock_advisories[2].should_receive(:version_safe?).and_return(false)

      spec = Bundler::LazySpecification.new('actionpack', '2.3.5', nil)
      subject.check_for_unsafe_versions(spec).should == [mock_advisories[2]]
    end

    it 'returns array of all vulnerable versions' do
      mock_advisories[0].should_receive(:version_safe?).and_return(false)
      mock_advisories[2].should_receive(:version_safe?).and_return(false)

      spec = Bundler::LazySpecification.new('actionpack', '2.3.5', nil)
      subject.check_for_unsafe_versions(spec).should == [mock_advisories[0], mock_advisories[2]]
    end
  end

  context '#load' do
    let(:cli) { double('cli')}
    it "gets advisory store if it doesn't exist" do
      cli.stub(:git_dir).and_return('/git_dir')
      cli.stub(:advisory_url).and_return('http://advisory-url')

      AdvisoryRepository.should_receive(:git_dir_exists?).with('/git_dir').and_return(false)
      AdvisoryRepository.should_receive(:clone_advisory_repo).with('http://advisory-url', '/git_dir').and_return(['success', 0])
      AdvisoryRepository.should_receive(:advisory_files).with('/git_dir').and_return(%w(file1 file2))

      Advisory.should_receive(:load).with('file1').and_return(mock_advisories[0])
      Advisory.should_receive(:load).with('file2').and_return(mock_advisories[2])

      repo = AdvisoryRepository.load(cli)
      repo['actionpack'].length.should == 2
    end

    it 'uses existing store' do
      cli.stub(:git_dir).and_return('/git_dir')
      cli.stub(:advisory_url).and_return('http://advisory-url')

      AdvisoryRepository.should_receive(:git_dir_exists?).with('/git_dir').and_return(true)
      AdvisoryRepository.should_receive(:update_git_dir).with('/git_dir').and_return(['success', 0])
      AdvisoryRepository.should_receive(:advisory_files).and_return(%w(file1 file2))

      Advisory.should_receive(:load).with('file1').and_return(mock_advisories[0])
      Advisory.should_receive(:load).with('file2').and_return(mock_advisories[2])

      repo = AdvisoryRepository.load(cli)
      repo['actionpack'].length.should == 2
    end

    it 'throws an error when clone fails' do
      cli.stub(:git_dir).and_return('/git_dir')
      cli.stub(:advisory_url).and_return('http://advisory-url')

      AdvisoryRepository.should_receive(:git_dir_exists?).with('/git_dir').and_return(false)
      AdvisoryRepository.should_receive(:clone_advisory_repo).with('http://advisory-url', '/git_dir').and_return(['git clone failed', 1])

      expect { AdvisoryRepository.load(cli) }.to raise_error(RepositoryDownloadException, 'git clone failed')
    end

    it 'throws an error when update fails' do
      cli.stub(:git_dir).and_return('/git_dir')
      cli.stub(:advisory_url).and_return('http://advisory-url')

      AdvisoryRepository.should_receive(:git_dir_exists?).with('/git_dir').and_return(true)
      AdvisoryRepository.should_receive(:update_git_dir).with('/git_dir').and_return(['git update failed', 1])

      expect { AdvisoryRepository.load(cli) }.to raise_error(RepositoryUpdateException, 'git update failed')
    end
  end

  context '#execute' do
    it 'can run a valid command and get stdout and exit code' do
      output, exit_code = AdvisoryRepository.send(:execute, 'echo TEST')
      output.should == "TEST\n"
      exit_code.should == 0
    end

    it 'can a run an invalid command and get stdout and exit code' do
      output, exit_code = AdvisoryRepository.send(:execute, 'ls 45fdgfg')
      output.should == "ls: cannot access 45fdgfg: No such file or directory\n"
      exit_code.should == 2
    end

    it 'can run an valid command and get stderr and exit code' do
      output, exit_code = AdvisoryRepository.send(:execute, 'ruby -e \'warn "This message goes to stderr"\'')
      output.should == "This message goes to stderr\n"
      exit_code.should == 0
    end
  end
end