#!/usr/bin/ruby

require 'rubygems'
require 'net/scp'
require 'net/ssh'
require 'colorize'


def help
	puts "###################HELP"
	puts "Options are:"
	puts "--username "
	puts "--password "
	puts "or"
	puts "--privatekey"
	puts "--sourceiplist "
	puts "--sourcecommandlist"
	puts "Command example: ./spreadCommands.rb --username root --password pass --sourceiplist ./ipListFiles/test.list --sourcecommandlist ./commandFiles/commands1.list"
end

sourceIp=nil
sourceCommand=nil
username=nil
password=nil
privkey=nil

argCount=0
limit=ARGV.length
while argCount < limit
	case ARGV[argCount]
	when "--username"
		argCount += 1
		username=ARGV[argCount]
	when "--password"
		argCount += 1
		password=ARGV[argCount]
	when "--privatekey"
		argCount += 1
		privkey=ARGV[argCount]
	when "--sourceiplist"
		argCount += 1
		sourceIp=ARGV[argCount]
	when "--sourcecommandlist"
		argCount += 1
		sourceCommand=ARGV[argCount]
	when "--help"
		help
		exit 0	
	else
		puts "This option is not recognized by the program: #{ARGV[argCount]}"
		exit 0
	end
	argCount += 1
end

#puts "user=#{username} pass=#{password} privK=#{privkey} sourceip=#{sourceIp} sourcecommandlist=#{sourceCommand}"

error=0
if password.nil? and privkey.nil?
	puts "ERROR: No password or privatekey was provided...one of them needs to be present"
	error=1
end

if sourceCommand.nil? or sourceIp.nil?
	puts "ERROR: sourceip address and source command files need to be present"
	error=1
end

if sourceIp.nil?
	puts "ERROR: This program requires an input file containing a list of ip addresses"
	error=1
end

if sourceCommand.nil?
	puts "ERROR: This program requires an input file contanining a list of commands to be executed"
	error=1
end

if error > 0
	help	
	puts "EXIT"
	exit 1
end

ipAddrList=Array.new
ipAddrCount=0
puts "List of ip addresses..."
begin
	handlerIp=File.open(sourceIp, "r")
	text=handlerIp.read
	text.each_line do |line|
		line.gsub("\n", "")
		ipAddrList[ipAddrCount]=line.split(" ")[0]
		puts "--#{ipAddrCount} #{ipAddrList[ipAddrCount]}"
		ipAddrCount += 1
	end
rescue
	puts "ERROR: open file #{sourceIp} was not OK"
	exit 1
ensure 
	handlerIp.close unless handlerIp.nil?
end

commandList=Array.new
commandCount=0
puts "List of commands..."
begin 
	handlerFiles=File.open(sourceCommand, "r")
	text=handlerFiles.read
	text.each_line do |line|
		line.gsub!("\n", '')
		commandList[commandCount]=line
		puts "--#{commandCount} --#{commandList[commandCount]}--"
		commandCount += 1
	end
rescue
	puts "ERROR: open file #{sourceCommand} was not OK || or something wrong in the read file code"
	exit 1
ensure
	handlerFiles.close unless handlerFiles.nil?
end

puts "commands executed accorss the network"
puts "#######################"
for i in 0..ipAddrCount-1
	puts "Login to machine: #{ipAddrList[i]}"
	begin
		if privkey.nil? 
			ssh = Net::SSH.start("#{ipAddrList[i]}", "#{username}", :password => "#{password}")
		else
			ssh = Net::SSH.start("#{ipAddrList[i]}", "#{username}", :keys => "#{privkey}") 	
		end
		hostn=ssh.exec!("hostname")
		puts "Login looks OK: hostname=#{hostn}"	
		for j in 0..commandCount-1
			puts "Execute command: #{commandList[j]}"
			output=ssh.exec!("#{commandList[j]}")
			puts "OUTPUT:"
			puts "#{output}".red
			puts "###"
		end
	rescue Exception => e
		puts "ERROR: something went wrong in the ssh commands code"
		puts "..#{e.message}"
	end
		puts "###########################"
end
