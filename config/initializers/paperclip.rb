# -*- encoding : utf-8 -*-
Paperclip::Attachment.default_options[:storage] = :fog
Paperclip::Attachment.default_options[:fog_credentials] = { 
	:provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],                        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],                        # required
    :region                 => 'sa-east-1'                  # optional, defaults to 'us-east-1'}
}

Paperclip::Attachment.default_options[:fog_directory] = ENV['AMAZON_BUCKET']
Paperclip::Attachment.default_options[:fog_host] = ENV['ASSET_HOST']
Paperclip::Attachment.default_options[:fog_public] = true
