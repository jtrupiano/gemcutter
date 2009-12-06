Given /^I have a gem "([^\"]*)" with version "([^\"]*)"$/ do |name, version|
  build_gem(name, version)
end

Given /^I have a gem "([^\"]*)" with version "([^\"]*)" and summary "([^\"]*)"$/ do |name, version, summary|
  build_gem(name, version, summary)
end

Given /^I have a gem "([^\"]*)" with version "([^\"]*)" and platform "([^\"]*)"$/ do |name, version, platform|
  build_gem(name, version, "Gemcutter", platform)
end

Given /^a rubygem exists with name "([^\"]*)" and rubyforge project "([^\"]*)"$/ do |name, rubyforge_project|
  rubygem = Factory(:rubygem, :name => name)
  Factory(:version, :rubygem => rubygem, :rubyforge_project => rubyforge_project)
end

Given /^the gem "([^\"]*)" with version "([^\"]*)" has been indexed$/ do |name, version|
  rubygem = Rubygem.find_by_name!(name)
  rubygem.versions.find_by_number(version).update_attribute(:indexed, true)
end

Given /^I have have already deleted the gem "([^\"]*)" with version "([^\"]*)" with my api key$/ do |name, version|
  rubygem = Rubygem.find_by_name!(name)
  rubygem.versions.find_by_number(version).yank!
end

def build_gem(name, version, summary = "Gemcutter", platform = "ruby")
  builder = Gem::Builder.new(build_gemspec(name, version, summary, platform))
  builder.ui = Gem::SilentUI.new
  builder.build
end

def build_gemspec(name, version, summary, platform)
  Gem::Specification.new do |s|
    s.name = "#{name}"
    s.platform = "#{platform}"
    s.version = "#{version}"
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["John Doe"]
    s.date = "#{Time.now.strftime('%Y-%m-%d')}"
    s.description = "#{summary}"
    s.email = "john.doe@example.org"
    s.files = []
    s.homepage = "http://example.org/#{name}"
    s.require_paths = ["lib"]
    s.rubygems_version = %q{1.3.5}
    s.summary = "#{summary}"
    s.test_files = []
  end
end
