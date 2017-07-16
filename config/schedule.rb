# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end



#env :PATH, ENV['PATH']
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
#job_type :runner, "cd #{path} && RAILS_ENV=development /home/ubuntu/.rvm/wrappers/ruby-2.4.0/bundle exec rails runner ':task' :output"
job_type :runner,  "cd :path && bundle exec rails runner -e :environment ':task' :output"

set :environment, :development 
every 1.day do
   runner 'StatusLoan.loans_payment', output: { error: "#{path}/log/error.log", standard: "#{path}/log/cron.log"}
end

# Learn more: http://github.com/javan/whenever
