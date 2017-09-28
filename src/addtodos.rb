#! /usr/bin/env ruby
#
# addtodos.rb -- add a list of tasks, grouped by context and label, to
# todo.txt
#
# Example file structure:
#
# @context1
# +label1
# to do item 1
# to do item 2
# +label2
# to do item 3
# @context2
# +label3
# to do item 4
#
# etc.
#
# This will add the to-do items with the prior context and label to todo.txt:
#
# todo add @context1 +label1 to do item 1
# todo add @context1 +label1 to do item 2
# todo add @context1 +label2 to do item 3
# todo add @context2 +label3 to do item 4
#

class TodoReader
  def initialize
    @input_file = 'todos.txt'
    @context = ''
    @label = ''
  end

  def read
    File.open(@input_file, 'r').each_line do |line|
      case line
      when /^#/ then # ignore comment line
      when /^@/ then set_context line
      when /^\+/ then set_label line
      else add_todo line
      end
    end
  end

  def set_context(line)
    @context = line.split(' ').first
  end

  def set_label(line)
    @label = line.split(' ').first
  end

  def add_todo(line)
    cmd = "todo add #{@context} #{@label} #{line}"

    puts cmd
    %x[ #{cmd} ]
  end

end

TodoReader.new.read
