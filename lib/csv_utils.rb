class CsvUtils
	require 'charlock_holmes'
	def self.read_file(csv_file)
		contents = csv_file.read
		csv_file.close
		detection = CharlockHolmes::EncodingDetector.detect(contents)
		contents.force_encoding detection[:encoding]
    	contents.encode! "UTF-8"
    	contents
	end
end