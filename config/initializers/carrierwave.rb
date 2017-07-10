# -*- encoding : utf-8 -*-
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],                        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],                        # required
    :region                 => 'sa-east-1'                  # optional, defaults to 'us-east-1'
   #  :host                   => 's2go.s3-sa-east-1.amazonaws.com'            # optional, defaults to nil
    # :endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = 'efinding-moller'                     # required
  config.fog_public     = true                                   # optional, defaults to true
  config.asset_host = 'https://d3isa1mztk678k.cloudfront.net'
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end


