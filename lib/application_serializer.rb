# -*- encoding : utf-8 -*-
require 'jsonapi-serializers'

class ApplicationSerializer
  include JSONAPI::Serializer
  
  def self_link
  	nil
  end
end
