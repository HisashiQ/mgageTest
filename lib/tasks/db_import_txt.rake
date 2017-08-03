require 'fileutils'

namespace :db do
	desc "Parse and update database with SMS voting results from txt file"
	task :import_txt => :environment do |t, args|

		# Variable that need instantiating before the body executes
		vote_row = []
		file_path = ENV['SMS_DATA'].to_s
		discarded_errors = 0
		wrong_time = 0

		if File.exists?(file_path)
			begin
				File.open(file_path, 'a+') do |l|
					candidates = map_current_candidates
					campaigns = map_current_ca mpaign
					while (line = l.gets)
						if line.valid_encoding?
							tokens = line.split(' ')
							cand_name = get_candidate_name(tokens)
							if !entry_exists?(candidates, cand_name)
								object = Candidate.new({name: cand_name})
								if object.save
									puts "Candidate: #{cand_name} saved"
								end
							end
							camp_name = get_campaign_name(tokens)
							if !entry_exists?(campaigns, camp_name)
								object = Campaign.new({name: camp_name})
								if object.save
									puts "Campaign: #{camp_name} saved"
								end
							end
							if valid?(tokens)
								candidates = map_current_candidates
								campaigns = map_current_campaign
								candidate_id = get_id(candidates, get_candidate_name(tokens))
								campaign_id = get_id(campaigns, get_campaign_name(tokens))
								if early_or_late?(tokens)
									camp = Campaign.find(campaign_id)
									err_count = camp.errors_count.to_i + 1
									camp.update(errors_count: err_count)
									wrong_time += 1
								else
									vote_row.push({'received_timestamp' => create_timestamp(tokens), 'candidate_id' => candidate_id, 'campaign_id' => campaign_id})
								end
							else
								discarded_errors += 1
							end
						else
							discarded_errors += 1
						end
					end
				end
			rescue Exception => msg
				puts "An error occured with the following message:\n\n#{msg}"
			end

			# Bulk save votes so that one SQL insert statement is made rather than one for each vote
			begin
				Vote.import vote_row, :validate => true
				puts "#{vote_row.size} votes were saved"
			rescue Exception => msg
				puts "An error occured with the following message whilst trying to batch update the Votes tables:\n\n#{msg}"
			end
		else
			puts "File does not exist.\nNo changes made to database.\nLocate file and provide the absolute path to it"
		end
		puts "#{discarded_errors} lines were invalid and discarded"
		puts "#{wrong_time} texts were sent before or after the valid time"
	end

##### The following methods are helpers to reduce duplicated code and in many cases,
##### reduce search and SQL queries

# Check format of lines is correct
	def valid?(line_token)
		line_token[0] == 'VOTE' && line_token[1].scan(/\D/).empty? && line_token[2].scan(/^Campaign:[a-zA-Z]+/).any? && line_token[3].scan(/^Validity:(during|pre|post)/) && line_token[4].scan(/^Choice:[a-zA-Z]+/).any?
	end


# check if vailidity is pre or post
	def early_or_late?(line_token)
		line_token[3].scan(/^Validity:(pre|post)/).any?
	end

# Check if entry exists, passing an active record model and the name of the candidate or campaign
	def entry_exists?(model, name)
		bool = false
		model.each do |hash|
			hash.each do |k, v|
				if v == name
					bool = true
				end
			end
		end
		bool
	end

# Create hash of ID : name for candidates to reduce SQL queries
	def map_current_candidates
		obj = Candidate.all
		obj.map { |i| {i.id => i.name} }
	end

# Create hash of ID : name for campaigns to reduce SQL queries
	def map_current_campaign
		obj = Campaign.all
		obj.map { |i| {i.id => i.name} }
	end

	def get_candidate_name(line)
		name_arr = line[4].split(":")
		name_arr[1]
	end

	def get_campaign_name(line)
		name_arr = line[2].split(":")
		name_arr[1]
	end

# Gets model ID based on model and record name
	def get_id(model, name)
		id = 0
		model.each do |hash|
			hash.each do |k, v|
				if v == name
					id = k.to_i
				end
			end
		end
		id
	end

# Convert epoch to datetime
	def create_timestamp(line)
		Time.strptime(line[1], '%Q')
	end

end
