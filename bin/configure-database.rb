#!/usr/bin/env ruby
require 'yaml'

rails_env = ENV['RAILS_ENV'] || 'test'

config =
  if File.exist? 'config/database_cider-ci.yml'
    YAML.load_file('config/database_cider-ci.yml')[rails_env]
  elsif File.exist? 'config/database.yml'
    YAML.load_file('config/database.yml')[rails_env]
  else
    YAML.load "
      adapter: sqlite3
      pool: 5
      timeout: 5000 "
  end

config.merge!(
  case config['adapter']
  when 'sqlite3'
    { 'database' => "db/#{rails_env}.sqlite3" }
  when 'postgresql'
    { 'database' => "#{rails_env}_#{ENV['CIDER_CI_TRIAL_ID']}",
      'username' => ENV['PGUSER'],
      'password' => ENV['PGPASSWORD'] }
  when 'mysql2'
    { 'database' => "#{rails_env}_#{ENV['CIDER_CI_TRIAL_ID']}",
      'username' => ENV['MYSQL_USER'],
      'password' => Env['MYSQL_PASSWORD'] }
  else
    fail 'Adapter not supported'
  end)

File.open('config/database.yml', 'w') do |file|
  file.write({ rails_env => config }.to_yaml)
end
