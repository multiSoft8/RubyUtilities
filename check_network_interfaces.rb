#!/usr/bin/ruby 

OKV=0
WARNV=1
CRITV=2
UNKNV=3

interfaceText = `ip a`
interface = nil
interfaceCount = 0
ipAddress = nil
lastValueFile = "/var/tmp/lastpppValue.txt"
lastIpValue = nil
ipChangeText = nil
interfaceText.each_line do |line|
        if line.include?("ppp") and line.include?("POINTOPOINT")
                interface = line.split(":")[1].gsub(" ","")
                interfaceCount += 1
        end
        if !interface.nil? and interface.include?("ppp") and line.include?("inet")
                ipAddress = line.split(" ")[1]
        end
end
if interface.nil?
        puts "No ppp interface found"
        exit CRITV
end
if ipAddress.nil?
        puts "ppp interface found=#{interface} but no IP found"
        exit CRITV
end
if interfaceCount > 1
        puts "Strange: more than one ppp interface found"
        exit CRITV
end
if !File.exist?(lastValueFile)
        fileHandle = File.new(lastValueFile, "w")
        fileHandle.close
end
fileHandle = File.open(lastValueFile, "r")
fileText = fileHandle.read
fileHandle.close
if fileText
        fileText = fileText.gsub(" ","").gsub("\n","")
        lastIpValue = fileText
#       puts "old=#{lastIpValue}|"
#       puts "new=#{ipAddress}|"
        if ipAddress.eql?(lastIpValue)
                ipChangeText = "Same ip address."
        else
                ipChangeText = "IP address changed. old=#{lastIpValue}"
                fileHandle = File.new(lastValueFile, "w")
                fileHandle.puts(ipAddress)
                fileHandle.close
        end
end
puts "Interface and ip found int=#{interface} ip=#{ipAddress}. #{ipChangeText}"
exit OKV
