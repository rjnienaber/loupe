require 'spec_helper'

describe ConsoleFormatter do
  let(:advisory_one) do
    advisory_one = double('advisory_one')
    advisory_one.stub(:cve).and_return('2012-1098')
    advisory_one.stub(:url).and_return('http://osvdb.org/79726')
    advisory_one
  end

  let(:advisory_two) do
    advisory_two = double('advisory_two')
    advisory_two.stub(:cve).and_return('2013-1800')
    advisory_two.stub(:url).and_return('http://osvdb.org/show/osvdb/90742')
    advisory_two
  end

  it 'formats output for a single file' do
    file_path = '/home/user/applications/app_name/Gemfile.lock'

    results = {'activesupport (2.2.2)' => [advisory_one], 'crack (0.1.4)' => [advisory_two]}

    result = subject.format(file_path, results)

    expected = %Q{app_name/Gemfile.lock
  activesupport (2.2.2)
    cve: 2012-1098, http://osvdb.org/79726
  crack (0.1.4)
    cve: 2013-1800, http://osvdb.org/show/osvdb/90742
}
    result.should == expected
  end

  it 'formats output for a relative file' do
    file_path = 'Gemfile.lock'

    results = {'activesupport (2.2.2)' => [advisory_one]}

    result = subject.format(file_path, results)

    expected = %Q{./Gemfile.lock
  activesupport (2.2.2)
    cve: 2012-1098, http://osvdb.org/79726
}
    result.should == expected
  end

  it 'formats output for two advisories for a single gem' do
    file_path = './Gemfile.lock'

    results = {'activesupport (2.2.2)' => [advisory_one, advisory_two]}

    result = subject.format(file_path, results)

    expected = %Q{./Gemfile.lock
  activesupport (2.2.2)
    cve: 2012-1098, http://osvdb.org/79726
    cve: 2013-1800, http://osvdb.org/show/osvdb/90742
}
    result.should == expected
  end

  it 'formats output for no advisories' do
    file_path = './Gemfile.lock'

    result = subject.format(file_path, {})

    expected = 'No vulnerable gems found in ./Gemfile.lock'
    result.should == expected
  end
end