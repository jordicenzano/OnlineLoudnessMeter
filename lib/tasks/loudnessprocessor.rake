namespace :onlineloudnesscalc do
	desc "Compute loudness of onlineloudnesscalc app"
  	task calcloudness: :environment do
    	
    	puts "Start calc loudness task"

		while (!Signal.trap("TERM"))
			loudnessmeasure = LoudnessMeasure.find_by state: 'queued'

			if (loudnessmeasure.present?)
	  		  	puts "Find file: #{loudnessmeasure.name}"

	    		loudnessfilename = loudnessmeasure.localfilename + ".txt"

				cmd = "ffmpeg -nostats -i #{loudnessmeasure.localfilename} -filter_complex ebur128 -f null - 2> #{loudnessfilename}"
	  			puts "Computing loudness. Run command: #{cmd}"

	  			ret = `#{cmd}`

	  			if File.exist?(loudnessfilename)
	  				#Get loudness values fom ffmpeg result file
	  				res = `tail -n 10 #{loudnessfilename}`
	  				
	  				begin
	  					i = finifromresult res
	  					#Get LRA val file
						lra = finlrafromresult res
	  		
	  					puts "Loudness resukts: I = #{i} LUFS, LRA = #{lra} LU"

						loudnessmeasure.updateloudnessvalues i,lra
	  					loudnessmeasure.updatestate 'finished'

						puts "DB updated"

	  					#Clean up
	  					puts "Cleaning media up"
	  					File.delete (loudnessmeasure.localfilename)
	  				rescue
	  					puts "Error computing loudness data in the results file #{loudnessfilename}"
	  					loudnessmeasure.updatestate 'error'	
	  				end
	  			else
	  				puts "There is no loudness results file #{loudnessfilename}"
	  				loudnessmeasure.updatestate 'error'
	  			end
	  		else
	  			sleep (1.0)
			end	
		end

    	puts "End calc loudness task" 
  	end

private 

  	def finifromresult (res)
  		res.scan(/.I:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	end

  	def finlrafromresult (res)
		res.scan(/.LRA:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	end
end