namespace :onlineloudnesscalc do
	desc "Compute loudness of onlineloudnesscalc app"
  	task calcloudness: :environment do
    	puts "Start calc loudness task"

    	#Start threads
    	numofprocthreads = 1
    	thread = Array.new (numofprocthreads)

    	#Create exit file
    	exitfilename = 'exitfile'
    	createexitfile exitfilename
    	
		#Create threads
		i = 0
		while i < numofprocthreads do
			thread[i] = Thread.new(exitfilename){|pexitfilename| procthread(pexitfilename)}
   			i +=1
		end

		#Wait threads
		i = 0
		while i < numofprocthreads do
			thread[i].join
   			i +=1
		end

    	puts "End calc loudness task" 
  	end

  	def createexitfile (filename)
  		exitfile = Rails.root.join(filename)

		if File.exist?(exitfile)
			File.delete(exitfile)
		end
    	File.open(exitfile, "w+") do |f|
  			f.close
		end
  	end

  	def finifromresult (res)
  		res.scan(/.I:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	end

  	def finlrafromresult (res)
		res.scan(/.LRA:[ ]+[-,0-9]+/).last.scan(/[-,0-9]+/).first.to_f
  	  end

  	def procthread (exitfile)

		puts "Enter proc thread id:#{Thread.current.object_id}"

		dteini = File.mtime(exitfile)
		dtenow = dteini

		while (dtenow == dteini)
			loudnessmeasure = LoudnessMeasure.find_by state: 'queued'

			if (loudnessmeasure.present?)
	  		  	puts "Find file: #{loudnessmeasure.name}"

	    		loudnessfilename = loudnessmeasure.localfilename + ".txt"

				cmd = "ffmpeg -nostats -i #{loudnessmeasure.localfilename} -filter_complex ebur128 -f null - 2> #{loudnessfilename}"
	  			puts "Run command: #{cmd}"

	  			ret = `#{cmd}`

	  			if File.exist?(loudnessfilename)
	  				#Get I val file
	  				res = `tail -n 10 #{loudnessfilename}`
	  				i = finifromresult res
	  				#Get LRA val file
					lra = finlrafromresult res
	  		
					loudnessmeasure.updateloudnessvalues i,lra
	  				loudnessmeasure.updatestate 'finished'

	  				#Clean up
	  				File.delete (loudnessmeasure.localfilename)
	  			else
	  				puts "There is no loudness results file #{loudnessfilename}"
	  				loudnessmeasure.updatestate 'error'
	  			end
	  		else
	  			sleep (1.0)
			end

			dtenow = File.mtime(exitfile)
	
		end

    	puts "Exit proc thread id:#{Thread.current.object_id}}"

	end
end