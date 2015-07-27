require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Rename < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Rename record or change attribute

					SYNOPSIS
						#{program_name} [options] id0 value

					DESCRIPTION
						Rename record or change attribute.  Rename a record unless
						option is specified.

					SEE ALSO
						http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
				opt.on("--stone_type", "Change stone_type") {|v| OPTS[:stone] = v}
				opt.on("--description", "Change description") {|v| OPTS[:description] = v}
				opt.on("--parent_id", "Change parent_id") {|v| OPTS[:parent_id] = v}
				opt.on("--place_id", "Change place_id") {|v| OPTS[:place_id] = v}
				opt.on("--box_id", "Change box_id") {|v| OPTS[:box_id] = v}
				opt.on("--physical_form_id", "Change physical_form_id") {|v| OPTS[:physical_form_id] = v}
				opt.on("--classification_id", "Change classification_id") {|v| OPTS[:classification_id] = v}
				opt.on("--quantity", "Change quantity") {|v| OPTS[:quantity] = v}
				opt.on("--quantity_unit", "Change quantity_unit") {|v| OPTS[:quantity_unit] = v}
				opt.on("--global_id", "Change global_id") {|v| OPTS[:global_id] = v}

			end
			opts
		end

		def rename(id, newparam)
			obj = Record.find(id)
			p obj if OPTS[:verbose]
			if OPTS[:id]
			  # obj.id                = newparam
			  # obj.update_record_property({:id => newparam})
			elsif OPTS[:stone]
			  obj.stone_type        = newparam
			elsif OPTS[:description]
			  obj.description       = newparam
			elsif OPTS[:parent_id]
			  obj.parent_id         = newparam
			elsif OPTS[:place_id]
			  obj.place_id          = newparam
			elsif OPTS[:box_id]
			  obj.box_id            = newparam
			elsif OPTS[:physical_form_id]
			  obj.physical_form_id  = newparam
			elsif OPTS[:classification_id]
			  obj.classification_id = newparam
			elsif OPTS[:quantity]
			  obj.quantity          = newparam
			elsif OPTS[:quantity_unit]
			  obj.quantity_unit     = newparam
			elsif OPTS[:global_id]
			  # obj.global_id         = newparam
			  obj.update_record_property({:global_id => newparam})
			else
			  obj.name              = newparam
			end
			puts obj.save
			p obj.reload if OPTS[:verbose]

		end

		def execute
			if argv.length != 2
				raise "specify id and newparam"
			else
				newparam = argv[1]
				id = argv[0]
			end

			rename(id, newparam)
		end	

	end
end