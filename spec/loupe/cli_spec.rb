require 'spec_helper'

describe Cli do
  let(:args) { [''] }
  subject { Cli.new(args) }

  describe "parses valid command with" do
    context "default parameters" do
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--gemfile" do
      let(:args) { %w(--gemfile ../Gemfile) }
      its(:gem_files) { should == ['../Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--gemfile (multiple)" do
      let(:args) { %w(--gemfile ../Gemfile,./Gemfile) }
      its(:gem_files) { should == ['../Gemfile', './Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--g" do
      let(:args) { %w(-g ../Gemfile) }
      its(:gem_files) { should == ['../Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--lockfile (multiple)" do
      let(:args) { %w(--lockfile ../Gemfile.lock,./Gemfile.lock) }
      its(:gem_files) { should == []}
      its(:lock_files) { should == ['../Gemfile.lock', './Gemfile.lock']}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--lockfile" do
      let(:args) { %w(--lockfile ../Gemfile.lock) }
      its(:gem_files) { should == []}
      its(:lock_files) { should == ['../Gemfile.lock']}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-l" do
      let(:args) { %w(-l ../Gemfile.lock) }
      its(:gem_files) { should == []}
      its(:lock_files) { should == ['../Gemfile.lock']}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-l and -g" do
      let(:args) { %w(-l ../Gemfile.lock -g ../Gemfile) }
      its(:gem_files) { should == ['../Gemfile']}
      its(:lock_files) { should == ['../Gemfile.lock']}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-l and -g with array" do
      let(:args) { %w(-l ../Gemfile.lock -g ../Gemfile,./Gemfile) }
      its(:gem_files) { should == ['../Gemfile', './Gemfile']}
      its(:lock_files) { should == ['../Gemfile.lock']}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-r" do
      let(:args) { %w(-r /home/user/.advisory_db) }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/home/user/.advisory_db'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--repo-location" do
      let(:args) { %w(--repo-location /home/user/.advisory_db) }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/home/user/.advisory_db'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-u" do
      let(:args) { %w(-u https://github.com/rjnienaber/ruby-advisory-db.git) }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rjnienaber/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--repo-url" do
      let(:args) { %w(--repo-url https://github.com/rjnienaber/ruby-advisory-db.git) }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rjnienaber/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "--advisory-db-sha" do
      let(:args) { %w(--advisory-db-sha) }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_true}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end

    context "-s" do
      let(:args) {['-s'] }
      its(:gem_files) { should == ['./Gemfile']}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_true}
      its(:git_dir) { should == '/var/lib/loupe_advisories'}
      its(:advisory_url) { should == 'https://github.com/rubysec/ruby-advisory-db.git'}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_true}
    end
  end

  describe "handles invalid parameters" do
    context "-x (unrecognised parameter)" do
      let(:args) {['-x'] }
      its(:gem_files) { should == []}
      its(:lock_files) { should == []}
      its(:show_advisory_db_sha) { should be_false}
      its(:git_dir) { should == ''}
      its(:advisory_url) { should == ''}
      its(:resolve_remotely) { should be_false}
      its(:valid?) { should be_false}
    end
  end
end
