# frozen_string_literal: true

require_relative "lib/hivehook/version"

Gem::Specification.new do |s|
  s.name        = "hivehook"
  s.version     = Hivehook::VERSION
  s.summary     = "Official Ruby client for Hivehook, webhook infrastructure for modern teams (inbound and outbound)."
  s.description = "Ruby client for Hivehook, webhook infrastructure for modern teams (inbound and outbound). Manage sources, destinations, subscriptions, applications, endpoints, and verify inbound webhook signatures."
  s.authors     = ["Hivehook"]
  s.email       = ["hello@hivehook.com"]
  s.homepage    = "https://hivehook.com"
  s.license     = "MIT"
  s.files       = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  s.required_ruby_version = ">= 3.0"

  s.metadata = {
    "homepage_uri"          => "https://hivehook.com",
    "source_code_uri"       => "https://github.com/hivehook/sdk-ruby",
    "bug_tracker_uri"       => "https://github.com/hivehook/sdk-ruby/issues",
    "documentation_uri"     => "https://hivehook.com/docs",
    "rubygems_mfa_required" => "true",
  }

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 13.0"
end
