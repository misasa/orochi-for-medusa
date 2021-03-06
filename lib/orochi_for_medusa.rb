require "orochi_for_medusa/version"
require "orochi_for_medusa/cui"
require "orochi_for_medusa/runner"
require "orochi_for_medusa/command_manager"
require "optparse"
require "logger"

require "medusa_rest_client"
require "unindent"
module OrochiForMedusa
  include MedusaRestClient

  # Your code goes here...
end


module MedusaRestClient
  class MyAssociation
    def empty?
      collection = to_a
      array = collection.to_a
      array.empty?
    end
  end
end