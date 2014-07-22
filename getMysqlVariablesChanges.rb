#!/usr/bin/ruby

require 'mysql'

username=nil
password=nil
host=nil
port=nil
iterations=nil

def help
        puts "###################HELP"
        puts "Options are:"
        puts "--username "
        puts "--password "
	puts "--iterations #if it is not set, then it defaults to 10"
	puts "--host #if it is not set, then it defaults to localhost"
	puts "--port #if it is not set, then it defaults to 3306"
	puts "Command example: ./getMysqlVariablesChanges.rb --username root --password pass"
end


argCount = 0
limit=ARGV.length
while argCount < limit
        case ARGV[argCount]
        when "--username"
                argCount += 1
                username=ARGV[argCount]
        when "--password"
                argCount += 1
                password=ARGV[argCount]
        when "--host"
                argCount += 1
                host=ARGV[argCount]
        when "--port"
                argCount += 1
                port=ARGV[argCount]
	when "--iterations"
		argCount += 1
		iterations=ARGV[argCount]	
        when "--help"
                help
                exit 0
        else
                puts "This option is not recognized by the program: #{ARGV[argCount]}"
                exit 0
        end
        argCount += 1
end

error = 0

if username.nil?
	puts "ERROR: No username was provided. A username is needed"
	error += 1
end

if password.nil?

	puts "ERROR: No password was provided. A password is needed"
	error += 1
end

if host.nil?
	host="localhost"
end

if port.nil?
	port="3306"
end

if iterations.nil?
	iterations=2
end

if error > 0
	help
	puts "EXIT"
	exit 1
end

status = Hash.new
statusNew = Hash.new
variables = Hash.new

begin
	connection = Mysql.new(host, username, password)
	puts "INFO #{connection.get_server_info}"
	resource = connection.query("show variables")
	resource.each do |stat, value|
		variables["#{stat}"] = value
	end
	count = 0
	while count < iterations
		resource = connection.query("show status")	
        	resource.each do |stat, value|
                	status["#{stat}"] = value
        	end
		sleep 1
		resource = connection.query("show status")
		resource.each do |stat, value|
			statusNew["#{stat}"] = value
		end
		status.each_pair do |stat, value|
			newValue = statusNew["#{stat}"]
			if newValue != value
				diff = newValue.to_i - value.to_i
				puts "#{stat} => old=#{value} new=#{newValue} diff=#{diff}"
			end
		end
		count += 1
		puts "Iter #{count}"
	end
rescue Mysql::Error => e
	puts "ERROR, #{e.errno} - #{e.error}"
ensure
	connection.close if connection
end
