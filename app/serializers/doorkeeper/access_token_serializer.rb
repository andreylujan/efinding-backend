# -*- encoding : utf-8 -*-
class Doorkeeper::AccessTokenSerializer
	include JSONAPI::Serializer

	attribute :access_token
	attribute :refresh_token
end
