#! /usr/bin/env ruby
# fakenames.rb -- generate fake names

locale = 'nl_BE'
num_names = 10
column_separator = ' | '

first_names = File.readlines(locale + '/firstname.txt').map { |s| s.chomp }
last_names = File.readlines(locale + '/lastname.txt').map { |s| s.chomp }

def generate_user_name(first_name, last_name)
  initials = last_name.split(' ').map { |s| s[0] }.join.downcase
  first_name.downcase + initials
end


num_names.times do
  first_name = first_names.sample
  last_name = last_names.sample
  user_name = generate_user_name(first_name, last_name)

  puts "#{column_separator}#{first_name} #{last_name}#{column_separator}#{user_name}#{column_separator}"
end

