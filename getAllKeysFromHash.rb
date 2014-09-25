#!/usr/bin/ruby


exhash = {
	"fstuff_1" => "stuff1",
	"rstuff_2" => {
		"fstuff_1" => "stuff2",
		"rstuff_2" => {
			"fstuff_1" => "stuff3",
			"fstuff_2" => "stuff4",
			"fstuff_3" => "stuff5"
		}
	}
}

## the purpose if to return only rstuff_* keys

@all_keys = []

def get_hash_keys(small_hash)
	if small_hash.nil?
		puts "ret nil"
		return nil
	end
	small_keys = small_hash.keys
	small_keys.each do |key|
		puts "key=#{key}"
		temp_hash = small_hash[key]
		puts "temp_hash=#{temp_hash} -- #{temp_hash.class.name}"
		if temp_hash.class.name.eql? "Hash"
			@all_keys << key
			get_hash_keys(temp_hash)	
		end
	end
end

puts "Start the stuff"
puts "Hash=#{exhash}"
puts "##########################"
get_hash_keys(exhash)
puts "all_keys=#{@all_keys}"
