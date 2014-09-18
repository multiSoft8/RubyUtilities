#!/usr/bin/ruby

def get_first_to_delete(hash_file)
	minim = 9999999999
	keys = hash_file.keys
	keys.each do |key|
		if key.to_i < minim.to_i
			minim=key
		end
	end
	minim
end
		      

backups_to_keep=10
base_dir="/home/sysops/backup"
config_list = ["/etc/puppet/manifests/site.pp", "/etc/puppet/files/general_files", "/etc/icinga", "/usr/local/bin", "/etc/puppet/files/group*"]
checked_list = ""
existing_file_time = Hash.new
#1. remove some old backups
Dir.foreach(base_dir) do |file|
	if file.match(/dailyBackup_\d+.tar.gz/)
		file_time=file.gsub("dailyBackup_","").gsub(".tar.gz","")
		existing_file_time[file_time] = file
	end
end
if !existing_file_time.empty?
	existing_file_time.each_pair do |name, time|
		puts "file=#{name} -- time=#{time}"
	end
	count = existing_file_time.count
	puts "count=#{count}"
	if (count-backups_to_keep).to_i >= 1
		puts "count-backups_to_keep..."
		backups_to_keep.upto(count) do |iter|
			delete_key=get_first_to_delete(existing_file_time)
			delete_file="#{base_dir}/#{existing_file_time[delete_key]}"
			existing_file_time.delete(delete_key)
			File.delete(delete_file)
			puts "to delete #{delete_key} -- file=#{delete_file}"
		end
	end
end
#2. make the current backup
config_list.each do |path|
	if File.exist?(path)
		checked_list = "#{checked_list} #{path}"
	else
		puts "ProblemPath=#{path}"
	end
end
time=Time.new.to_i
file_name="#{base_dir}/dailyBackup_#{time}.tar.gz"
command="tar zcvf #{file_name} #{checked_list} 1>/dev/null"
exit_code=system(command)
if exit_code == false
	puts "Huston we have a problem"
else
	puts "Backup done for:"
	checked_list.split(' ').each do |item|
		puts "#{item}"
	end
#	puts "command=#{command}"
end

