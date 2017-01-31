# -*- encoding : utf-8 -*-
JSONAPI.configure do |config|

  # built in key format options are :underscored_key, :camelized_key and :dasherized_key
  config.json_key_format = :underscored_key
  config.route_format = :underscored_route
  config.default_paginator = :paged

  config.default_page_size = 99999
  config.maximum_page_size = 99999

  config.top_level_links_include_pagination = false
  config.always_include_to_one_linkage_data = false

  # Output the record count in top level meta data for find operations
  config.top_level_meta_include_record_count = true
  config.top_level_meta_record_count_key = :record_count

  # For :paged paginators, the following are also available
  config.top_level_meta_include_page_count = true
  config.top_level_meta_page_count_key = :page_count
  # config.top_level_meta_page_count_key = :page_count

end



Rails.configuration.to_prepare do

  PagedPaginator.class_eval do
    def calculate_page_count(record_count)
      if record_count.is_a? Hash
        ( record_count.values.sum / @size.to_f).ceil
      else
        (record_count / @size.to_f).ceil
      end
    end

  end

  JSONAPI::ResourceSerializer.class_eval do

    def link_object_to_one(source, relationship, include_linkage)
      include_linkage = include_linkage | @always_include_to_one_linkage_data | relationship.always_include_linkage_data
      link_object_hash = {}
      if include_linkage
        link_object_hash[:data] = to_one_linkage(source, relationship)
      else
        link_object_hash[:links] = {}
        link_object_hash[:links][:self] = self_link(source, relationship)
        link_object_hash[:links][:related] = related_link(source, relationship)
      end

      link_object_hash
    end

    def link_object_to_many(source, relationship, include_linkage)
      include_linkage = include_linkage | relationship.always_include_linkage_data
      link_object_hash = {}


      if include_linkage
        link_object_hash[:data] = to_many_linkage(source, relationship) if include_linkage
      else
        link_object_hash[:links] = {}
        link_object_hash[:links][:self] = self_link(source, relationship)
        link_object_hash[:links][:related] = related_link(source, relationship)
      end




      link_object_hash
    end

    JSONAPI::ActsAsResourceController.class_eval do
      def render_results(operation_results)
        response_doc = create_response_document(operation_results)

        render_options = {
          status: response_doc.status,
          json:   response_doc.contents,
          content_type: JSONAPI::MEDIA_TYPE
        }

        render_options[:location] = response_doc.contents[:data]["links"][:self] if (
          response_doc.status == :created &&
          response_doc.contents[:data] &&
          response_doc.contents[:data]["links"] &&
          response_doc.contents[:data].class != Array
        )

        render(render_options)
      end
    end

  end
end
