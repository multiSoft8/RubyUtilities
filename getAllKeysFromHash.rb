#!/usr/bin/ruby


exhash = {
	"gstuff_1" => "stuff1",
	"gstuff_2" => {
		"rstuff_1" => "stuff2",
		"rstuff_2" => {
			"fstuff_1" => "stuff3"
		}
	}
}

@all_keys = []

def get_hash_keys(small_hash)
	if small_hash.nil?
		puts "ret nil"
		return nil
	end
	small_keys = small_hash.keys
	small_keys.each do |key|
		puts "key=#{key}"
		@all_keys << key	
		temp_hash = small_hash[key]
		puts "temp_hash=#{temp_hash} -- #{temp_hash.class.name}"
		if temp_hash.class.name.eql? "Hash"
			get_hash_keys(temp_hash)	
		end
	end
end

puts "Start the stuff"
puts "Hash=#{exhash}"
puts "##########################"
get_hash_keys(exhash)
puts "all_keys=#{@all_keys}"
