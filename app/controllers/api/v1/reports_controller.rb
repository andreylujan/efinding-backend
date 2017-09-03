# -*- encoding : utf-8 -*-
class Api::V1::ReportsController < Api::V1::JsonApiController

  require 'zip'
  before_action :doorkeeper_authorize!

  def context
    super.merge({
      inspection_id: params[:inspection_id],
      report_type_id: params[:report_type_id]
    })
  end

  def mine
    params["action"] = "index"
    params["filter"] ||= {}
    params["filter"]["assigned_user_id"] = current_user.id
    params["filter"].delete "assigned_user"
    index
  end

  def tasks
    params["action"] = "index"
    params["filter"] ||= {}
    params["filter"]["assigned_user_id"] = current_user.id
    params["filter"].delete "assigned_user"
    index
  end

  def xlsx
    params["action"] = "index"
    params["all"] = true
    @zip = true
    
    @month = params[:month].present? ? params[:month].to_i : DateTime.now.month
    @year = params[:year].present? ? params[:year].to_i : DateTime.now.year
    @start_date = DateTime.new(@year, @month).beginning_of_month
    @end_date = DateTime.new(@year, @month).end_of_month
    
    reports = Report.includes(creator: :role)
    .includes(:assigned_user)
    .where(roles: { organization_id: current_user.organization_id })
    .where("reports.created_at >= ? AND reports.created_at <= ?", @start_date, @end_date)
    Report.setup_xlsx(current_user.organization_id)
    xlsx = reports.to_xlsx
    send_data(xlsx.to_stream.read, :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
     :filename => 'reports.xlsx')
  end

  def show
    if params[:format] == "html"
      report = Report.find(params[:id])
      template = report.report_type.pdf_templates.first
      render(inline: template.template, locals: { report: report })
    elsif params[:format] == "pdf"
      report = Report.find(params[:id])
      template = report.report_type.pdf_templates.first
      html = render_to_string(inline: template.template, locals: { report: report })
        .force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.75)
      render body: pdf
    else
      super
    end
  end

  def create
    params.permit!
    super
  end

  def update
    params.permit!
    super
  end
  
  def zip
    params["action"] = "index"
    params["all"] = true
    @zip = true
    reports = get_records_without_render.results.first.resources
    pdf_urls = reports.select { |r| r.pdf_uploaded }.map { |r| r.pdf }
    temp_file = Tempfile.new('reports_' + SecureRandom.uuid.to_s + '.zip')
    
    begin
      Zip::OutputStream.open(temp_file) do |zipfile|
        pdf_urls.each do |pdf|
          filename = pdf.split("/")[-1]
          zipfile.put_next_entry(filename)
          zipfile.print(URI.parse(pdf).read)

          # zipfile.add(filename, file.path)
        end
      end
      zip_data = File.read(temp_file.path)
      send_data(zip_data, :type => 'application/zip', :filename => 'reports.zip')
    ensure
      #Close and delete the temp file
      temp_file.close
      temp_file.unlink
    end
  end

  def get_records_without_render
    @request = JSONAPI::RequestParser.new(params, context: context,
                                          key_formatter: key_formatter,
                                          server_error_callbacks: (self.class.server_error_callbacks || []))

    unless @request.errors.empty?
      render_errors(@request.errors)
    else
      operations = @request.operations
      unless JSONAPI.configuration.resource_cache.nil?
        operations.each {|op| op.options[:cache_serializer] = resource_serializer }
      end
      process_operations(operations)
    end
  rescue => e
    handle_exceptions(e)
  end

end
