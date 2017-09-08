source "https://rubygems.org"

gemspec

group :development do
  gem 'minitest'
  gem 'webmock'
  gem 'rake'
  platforms :mri do
    # to avoid problems, bring Byebug in on just versions of Ruby under which
    # it's known to work well
    if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.0.0')
      gem 'byebug'
    end
  end
end