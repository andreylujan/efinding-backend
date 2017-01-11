# -*- encoding : utf-8 -*-

cmd = "wkhtmltopdf"
exe_path = nil
exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
	exts.each do |ext|
		exe = File.join(path, "#{cmd}#{ext}")
		exe_path = exe if File.executable?(exe) && !File.directory?(exe)
	end
end


WickedPdf.config = {
  #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
  #:layout => "pdf.html",
  :exe_path => exe_path
}
