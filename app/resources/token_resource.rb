# -*- encoding : utf-8 -*-
class TokenResource < ApplicationResource
    attributes :access_token,
    :token_type,
    :expires_in,
    :refresh_token,
    :scope,
    :created_at
end
