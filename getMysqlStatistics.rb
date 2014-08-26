#!/usr/bin/ruby

require 'mysql'

username=nil
password=nil
host=nil
port=nil
iterations=nil
queryFile=nil
action=nil
getProfile=nil

def help
        puts "###################"
	puts "###################"
	puts "HELP:"
        puts "Options are:"
        puts "--username "
        puts "--password "
	puts "--iterations #if it is not set, then it defaults to 10"
	puts "--host #if it is not set, then it defaults to localhost"
	puts "--port #if it is not set, then it defaults to 3306"
	puts "--action #if not set, default is getStatusVariablesDiff"
	puts "  list of posible actions:"
	puts "   getStatusVariablesDiff"
	puts "   getProfileDataForQuery"
	puts "   getStatusVariablesForQuery"
	puts "Command example for action getStatusVariablesDiff: ./getMysqlStatistics.rb --username root --password pass --iterations 10"
	puts "Command example for action getProfileDataForQuery: ./getMysqlStatistics.rb --username root --password pass --action getProfileDataForQuery --setqueryfile fileQuery.sql"
	puts "Command example for action getStatusVariablesForQuery: ./getMysqlStatistics.rb --username root --password pass --action getStatusVariablesForQuery --setqueryfile fileQuery.sql"
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
		iterations=iterations.to_i
	when "--setqueryfile"
		argCount += 1
		queryFile=ARGV[argCount]	
	when "--action"
		argCount += 1
		action=ARGV[argCount]
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

if action.nil?
	        action="getStatusVariablesDiff"
end

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

if action.eql?("getStatusVariablesForQuery") and queryFile.nil?
	puts "ERROR: with this action: getStatusVariablesForQuery , the program needs --setqueryfile option"
	error += 1
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

	if action.eql?("getStatusVariablesDiff")
		resource = connection.query("show variables")
		resource.each do |stat, value|
			variables["#{stat}"] = value
		end
		count = 0
		while count < iterations
			resource = connection.query("show global status")	
	        	resource.each do |stat, value|
        	        	status["#{stat}"] = value
        		end
			sleep 1
			resource = connection.query("show global status")
			resource.each do |stat, value|
				statusNew["#{stat}"] = value
			end
			status.each_pair do |stat, value|
				newValue = statusNew["#{stat}"]
				if newValue != value
					diff = newValue.to_i - value.to_i
					puts "#{diff}\t\t#{stat}" 
				end
			end
			count += 1
			puts "###########################{count}"
		end
	elsif action.eql?("getStatusVariablesForQuery")
		count = 0
		fileHandler = File.open(queryFile, "r")
		queryData = fileHandler.read
		fileHandler.close()
		connection.query("flush status;")
		queryFinal = ""
		queryData.each do |queryLine|
			if queryLine.include?(";")
				queryFinal << queryLine
				connection.query(queryFinal)
			else
				queryFinal << queryLine
			end
		end
		resource = connection.query("show global status")
		resource.each do |stat, value|
			puts "#{value}\t\t\t#{stat}" if !value.eql?("0")
		end
	elsif action.eql?("getProfileDataForQuery")
		fileHandler = File.open(queryFile, "r")
		queryData = fileHandler.read
		fileHandler.close()
		connection.query("set profiling=1")
		queryData.each do |queryLine|
			connection.query(queryLine)
		end
		resource = connection.query("show profile")
		resource.each do |stat, value|
			puts "#{value}\t\t\t#{stat}"
		end		
	end
rescue Mysql::Error => e
	puts "ERROR, #{e.errno} - #{e.error}"
ensure
	connection.close if connection
end

