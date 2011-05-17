require 'fileutils'

namespace :server do

  desc "Start the server."
  task :start do
    puts "Attempting to start server."
    sh %{bash /home/ajey/NetBeansProjects/keyword/kea/start_kea_server.sh /home/ajey/NetBeansProjects/keyword/kea  }
    
  end
end

# to be removed
desc "Example of task with parameters and prerequisites"
task :my_task, [:first_arg, :second_arg] do |t, args|
  args.with_defaults(:first_arg => "Foo", :last_arg => "Bar")
  puts "First argument was: #{args.first_arg}"
  puts "Second argument was: #{args.last_arg}"
end
