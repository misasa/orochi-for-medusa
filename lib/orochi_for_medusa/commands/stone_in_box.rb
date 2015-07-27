require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class StoneInBox < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Transform stone to box

					SYNOPSIS
						#{program_name} [options] id0 [id1 ...]

					DESCRIPTION
						Transform stone to box.  This program changes the class of stone
						to box by follwing steps.

						(1) Create a new box with same name of specfied stone.

						(2) Copy attachments of stone to the box.

						(3) Store the stone into the box.

						(4) Swap IDs of them.

					SEE ALSO
						orochi-mkstone
						orochi-mv
						orochi-rename
						http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
				opt.on("-i", "--interactive", "Run interactively") {|v| OPTS[:interactive] = v}

			end
			opts
		end

		def execute
			if argv.length < 1
			  while answer = stdin.gets do
			    answer.split.each do |id|
			      get_and_put(id)
			    end
			  end
			else argv.each do |id|
			    get_and_put(id)
			  end
			end			
		end	


		def get_and_put(id)
		  @output = stdout
		  stone_obj = Record.find_by_id_or_path(id)
		  if OPTS[:interactive]
		    @output.puts "--> #{stone_obj.name} <#{stone_obj.class} with #{stone_obj.global_id} on #{stone_obj.created_at}>"
		    @output.print "I will create a new box |#{stone_obj.name}| and put your stone in it. Then I will swap ID of them. Are you sure you want to continue? (y/n [yes]) "
		    # yes_or_exit(params[:yes],'yes')
		    answer = (stdin.gets)[0].downcase
		    if answer == "y" or answer == "\n"
		      puts "You chose yes to this record" if OPTS[:verbose]
		    elsif answer == "!"
		      OPTS[:interactive] = false
		      puts "You chose yes to all" if OPTS[:verbose]
		    else
		      puts "You chose no for this record" if OPTS[:verbose]
		      raise
		    end
		    @output.puts "--> creating a new box |#{stone_obj.name}|..."
		  end
		  box_obj = Box.new
		  box_obj.name = stone_obj.name
		  box_obj.save
		  box_obj.reload
		  # dummy = Stone.new
		  # dummy.name = "deleteme.dummy"
		  # dummy.save
		  original_global_id = stone_obj.global_id
		  new_global_id = box_obj.global_id
		  box_obj.parent_id = stone_obj.box_id
		  stone_obj.attachment_files.each do |attachment|
		    box_obj.attachment_files << attachment
		  end
		  stone_obj.bibs.each do |bib|
		    box_obj.bibs << bib
		  end
		  @output.puts "--> #{box_obj.name} <#{box_obj.class} with #{box_obj.global_id}> was created." if OPTS[:interactive]
		  @output.puts "--> swapping ID (#{stone_obj.global_id}) between the stone and the box..." if OPTS[:interactive]
		  # box_obj.created_at = stone_obj.created_at
		  box_obj.update_record_property({:global_id => original_global_id + "-dup"})
		  stone_obj.update_record_property({:global_id => new_global_id})
		  box_obj.update_record_property({:global_id => original_global_id})
		  box_obj.box_type_id = 12      # mount
		  p box_obj if OPTS[:verbose]
		  p stone_obj if OPTS[:verbose]
		  # box_obj.global_id = stone_obj.global_id
		  # box_obj.id = stone_obj.id
		  # stone_obj.global_id = dummy.global_id
		  # stone_obj.id = dummy.id
		  # dummy.destroy
		  puts box_obj.save if OPTS[:verbose]
		  puts stone_obj.save if OPTS[:verbose]
		  @output.puts "--> putting your stone |#{stone_obj.name}| into the box |#{box_obj.name}|..." if OPTS[:interactive]
		  box_obj.relatives << stone_obj
		  @output.puts "done" if OPTS[:interactive]
		end



	end
end