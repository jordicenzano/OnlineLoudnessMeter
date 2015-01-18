namespace :onlineloudnesscalc do
	desc "Compute loudness of onlineloudnesscalc app"
  	task calcloudness: :environment do

			@bexit = false

			log "Start calc loudness task"

			while (@bexit == false)
				loudnessmeasure = LoudnessMeasure.find_by(state: 'queued')

				if (loudnessmeasure.present?)
					log "Find file: #{loudnessmeasure.name}"

	    		loudnessfilename = loudnessmeasure.localfilename + ".txt"

					cmd = "ffmpeg -nostats -i #{loudnessmeasure.localfilename} -filter_complex ebur128 -f null - 2> #{loudnessfilename}"

					log "Computing loudness. Run command: #{cmd}"

	  			ret = `#{cmd}`

					if File.exist?(loudnessfilename)
	  				#Get loudness values fom ffmpeg result file
	  				res = `tail -n 10 #{loudnessfilename}`

	  				begin
	  					i = finifromresult res

	  					#Get LRA val file
							lra = finlrafromresult res
							log "Loudness resukts: I = #{i} LUFS, LRA = #{lra} LU"

							loudnessmeasure.updateloudnessvalues i,lra
	  					loudnessmeasure.updatestate 'finished'

							log "DB updated"

	  					#Clean up
	  					log "Cleaning media up"
	  					File.delete (loudnessmeasure.localfilename)
	  				rescue
	  					log "Error computing loudness data in the results file #{loudnessfilename}"
	  					loudnessmeasure.updatestate 'error'
	  				end
	  			else
	  				log "There is no loudness results file #{loudnessfilename}"
	  				loudnessmeasure.updatestate 'error'
	  			end
	  		else
	  			sleep (1.0)
					log "Wait"
				end

				trap("INT"){@bexit = true}
				trap("TERM"){@bexit = true}

			end

			log "End calc loudness task"

		end

private 

  	def finifromresult (res)
  		res.scan(/.I:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	end

  	def finlrafromresult (res)
		res.scan(/.LRA:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	end

  	def log (str)
  		puts "#{DateTime.now.strftime("%Y-%m-%d %H:%M:%S.%N")} - #{str}"
			STDOUT.flush
  	end
end