# frozen_string_literal: true

require_relative 'lib/json_accessible/version'

Gem::Specification.new do |spec|
  spec.name = 'json_accessible'
  spec.version = JsonAccessible::VERSION
  spec.authors = ['PrimaryHealth']
  spec.email = ['damon.sawyer@primary.health']
  spec.summary = 'Json Accessible'
  spec.description = 'Json Accessible'
  spec.license = 'Unlicense'
  spec.homepage = 'https://github.com/PrimaryDotHealth/json_accessible'
  spec.required_ruby_version = '>= 2.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/PrimaryDotHealth/json_accessible/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?('bin/', 'test/', 'spec/', 'features/', '.git', '.circleci', 'appveyor')
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel', '~> 7.0', '>= 7.0.4.3'
  
  spec.add_development_dependency 'rails_helper', '~> 2.2', '>= 2.2.2'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'
end
