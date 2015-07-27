require 'orochi_for_medusa'


class Output
  def messages
    @messages ||= []
  end
  
  def puts(message)
    messages << message
  end

  def print(message)
    messages << message
  end
end


# def stdout
#  	@stdout ||= Output.new
# end

# def stderr
# 	@stderr ||= Output.new
# end

RSpec::Matchers.define :exit_with_code do |code|
	def supports_block_expectations?
		true
	end

	actual = nil
	match do |block|
		begin
			block.call
		rescue SystemExit => e
			actual = e.status
		end
		actual && actual == code
	end

	failure_message do |block|
		"expected block to call exit(#{code}) but exit" + (actual.nil? ? " not called" : "(#{actual}) was called" )
	end

	failure_message_when_negated do |block|
		"expected block not to call exit(#{code})"
	end

	description do
		"expect block to call exit(#{code})"
	end

end
