#!/usr/bin/ruby

require 'rubygems'
require 'net/scp'
require 'net/ssh'

def help
        puts "###################HELP"
        puts "Options are:"
        puts "--username "
        puts "--password "
        puts "or"
        puts "--privatekey"
        puts "--sourceiplist "
        puts "--sourcefilelist"
	puts "The sourcefile must have this format: filePath destinationPath"
	puts "Command example: ./spreadFiles.rb --username root --password pass --sourceiplist ./ipListFiles/test.list ./sourceFiles/changeChefIntervalTime.list"
end

sourceIp=nil
sourceFiles=nil
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
        when "--sourcefilelist"
                argCount += 1
                sourceFiles=ARGV[argCount]
        when "--help"
                help
                exit 0
        else
                puts "This option is not recognized by the program: #{ARGV[argCount]}"
                exit 0
        end
        argCount += 1
end


error=0

if password.nil? and privkey.nil?
        puts "ERROR: No password or privatekey was provided...one of them needs to be present"
	error=1
end

if sourceFiles.nil? or sourceIp.nil?
        puts "ERROR: sourceip address and source command files need to be present"
	error=1
end

if sourceIp.nil?
	puts "ERROR: This program requires an input file containing a list of ip addresses"
	error=1
end

if sourceFiles.nil?
	puts "ERROR: This program requires an input file contanining a list of files to be copyed + destinations on the remote"
	error=1
end

if error > 0
	help
	puts "EXIT"
	exit 1
end

ipAddrList=Array.new
destList=Array.new
ipAddrCount=0
puts "List of ip addresses..."
begin
	handlerIp=File.open(sourceIp, "r")
	text=handlerIp.read
	text.each_line do |line|
		line.gsub("\n", "")
		ipAddrList[ipAddrCount]=line.split(" ")[0]
		destList[ipAddrCount]=line.split(" ")[1]
		puts "--#{ipAddrCount} #{ipAddrList[ipAddrCount]} to #{destList[ipAddrCount]}"
		ipAddrCount += 1
	end
rescue
	puts "ERROR: open file #{sourceIp} was not OK"
ensure 
	handlerIp.close unless handlerIp.nil?
end

fileList=Array.new
fileCount=0
puts "List of files..."
begin 
	handlerFiles=File.open(sourceFiles, "r")
	text=handlerFiles.read
	text.each_line do |line|
		line.gsub!("\n", '')
		line.gsub!(" ", "")
		fileList[fileCount]=line
		puts "--#{fileCount} --#{fileList[fileCount]}--"
		fileCount += 1
	end
rescue
	puts "ERROR: open file #{sourceFiles} was not OK"
ensure
	handlerFiles.close unless handlerFiles.nil?
end

puts "Tring to spred some files across the network"
puts "#######################"
for i in 0..ipAddrCount-1
	begin
		Net::SCP.start("#{ipAddrList[i]}", "#{username}", :password => "#{password}") do |scp|
			puts "Login to #{ipAddrList[i]} looks OK"
			for j in 0..fileCount-1
				scp.upload!("#{fileList[j]}", "#{destList[i]}")
				puts "copy #{fileList[j]} to #{ipAddrList[i]}/#{destList[i]} -- OK"
			end
		end
	rescue Exception => e
		puts "ERROR: unable to copy the files"
		puts "..#{e.message}"
	end
		puts "###########################"
end
