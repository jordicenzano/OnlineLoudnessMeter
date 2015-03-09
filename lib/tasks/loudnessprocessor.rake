namespace :onlineloudnesscalc do
  desc "Compute loudness of onlineloudnesscalc app"
    task calcloudness: :environment do

      @bexit = false

      log "Start calc loudness task"

      while (@bexit == false)
        loudnessmeasure = LoudnessMeasure.getloudnessmeasuresqueuedtoprocess

        #TODO: Remember to recreate the DB in server machine!!!!!!!!!!!!
    
        begin

          if (loudnessmeasure.present?)
            log "Found file: #{loudnessmeasure.name}"

            #Load config data (makes possible to change config params on the fly)
            #TODO hide config
            localpath = "public"
            #User loudnessdownloader
            s3key = CONFIG_ONLINELOUDNESS['loudnessdownloader']['key']
            s3secret = CONFIG_ONLINELOUDNESS['loudnessdownloader']['secret']
            s3defaultregion = CONFIG_ONLINELOUDNESS['loudnessdownloader']['region']

            #generate local filenames
            localmediafilename = File.join(localpath,"#{SecureRandom.uuid}#{File.extname(loudnessmeasure.url)}")
            localresultfilename = File.join(localpath,"#{SecureRandom.uuid}.txt")
            #S3 Download
            log "Downloading from #{loudnessmeasure.url_plain} to #{localmediafilename}"
            loudnessmeasure.downloadfroms3 localmediafilename, s3key, s3secret, s3defaultregion

            #Calculate loudness
            #TODO: Change ffmper per http://jordicenzano.name/front-test/tv-loudness-metering-072013/command-line-loudness-meter/
            cmd = "ffmpeg -nostats -i #{localmediafilename} -filter_complex ebur128 -f null - 2> #{localresultfilename}"
            log "Computing loudness. Run command: #{cmd}"

            #Execute command
            ret = `#{cmd}`

            if !File.exist?(localresultfilename)
              raise "No loudness results file found in: #{localresultfilename}"
            end

            #Get loudness values fom ffmpeg result file
            res = `tail -n 10 #{localresultfilename}`
            #Get i value from res
            i = finifromresult res
            #Get LRA val from res
            lra = finlrafromresult res

            log "Loudness results: I = #{i} LUFS, LRA = #{lra} LU"

            #Update result in DB
            loudnessmeasure.updateloudnessvalues i,lra
            #Update state in DB
            loudnessmeasure.updatestate 'finished'

            log "DB updated"

          else
            #No measure to calc
            #log "There is no loudness measure to calc"
            sleep (2.0)
          end

        rescue Exception => e
              loudnessmeasure.updatestate 'error'
              log "Error computing loudness data Error: #{e.message}, #{e.backtrace}"
        ensure
          #Clean up (we won't delete file from s3, it will expire. And we'll be able to retry)
          if localmediafilename.present?
            log "Cleaning media up"
            if File.exist?(localmediafilename)
              File.delete (localmediafilename)
              log "Deleted: #{localmediafilename}"
            end
          end
        end

        sleep (0.1)

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