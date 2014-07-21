#!/usr/bin/ruby

puts "This script will take 2 directories from input and compare the file content by name of the files"

dir1=ARGV[0]
dir2=ARGV[1]

if dir1.nil? or dir2.nil?
	puts "One of the directories is not specified"
	exit 0
end

if ! File.exist?(dir1) or ! File.exist?(dir2)
	puts "One or both dirs do not exist"
	exit 0
end

if ! File.directory?(dir1) or ! File.directory?(dir2)
	puts "One or both dirs are not actually dir"
	exit 0
end

puts "Both directories exists and are directories"

dir1Files = Array.new
dir2Files = Array.new

dir1Handle = Dir.new(dir1)
dir2Handle = Dir.new(dir2)

dir1Text = ""
dir2Text = ""

dir1Handle.each do |file|
	dir1Files.push file
	dir1Text = dir1Text + file.to_s
	dir1Text = dir1Text + " "
end

dir2Handle.each do |file|
	dir2Files.push file
	dir2Text = dir2Text + file.to_s
	dir2Text = dir2Text + " "
end


puts "In #{dir1} are #{dir1Files.count}"
puts "In #{dir2} are #{dir2Files.count}"

diff21Count=0
dir2Files.each do |file|
	if ! dir1Text.include?(file)
		puts "File #{file} from #{dir2} does not exist on #{dir1}"
		diff21Count += 1
	end
end	

diff12Count=0
dir1Files.each do |file|
	if ! dir2Text.include?(file)
		puts "File #{file} from #{dir1} does not exist on #{dir2}"
		diff12Count += 1
	end
end


puts "################################################################################"
puts "There are #{diff21Count} files that exist in #{dir2} and do not exist in #{dir1}"
puts "There are #{diff12Count} files that exist in #{dir1} and do not exist in #{dir2}"

dir1Handle.close
dir2Handle.close
