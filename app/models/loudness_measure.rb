class LoudnessMeasure < ActiveRecord::Base
	validates :state, presence: true
	validates :name, presence: true, length: { minimum: 5 }
	validates :originalfilename, presence: true

	def hello
		"Hello!"
	end

	def updatestate (newstate)
		update ({:state => newstate})
	end

	def updateloudnessvalues (i, lra)
		update ({:loudnessi => i, :loudnesslra => lra})
	end

	def updatelocalfilename (filename)
		update ({:localfilename => filename})
	end
	
	def upload (uploadfile)
		#uploadfile = loudnessmeasure_params_uploadfile
		original_filename = uploadfile.original_filename
		localfilename = SecureRandom.uuid + File.extname(original_filename)

		localfilepathupload = Rails.root.join('public', 'uploads', '.' + localfilename)
		localfilepathfinal = Rails.root.join('public', 'uploads', localfilename)
	
		logger.debug "Start upload: from #{uploadfile} to #{localfilepathfinal}"
	
		File.open(localfilepathupload, 'wb') do |file|
    		file.write(uploadfile.read)
  			
    		file.close

    		File.rename localfilepathupload, localfilepathfinal
    	end

    	updatelocalfilename localfilepathfinal.to_s
    	updatestate 'queued'
	end
end
