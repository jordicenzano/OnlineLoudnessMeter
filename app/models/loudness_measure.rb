require 'fog'
require 'uri'

class LoudnessMeasure < ActiveRecord::Base

  belongs_to :user

  validates :state, presence: true
  validates :name, presence: true
  validates :url, presence: true, length: { minimum: 3 }

  def self.getloudnessmeasuresqueuedtoprocess
    loudnessmeasure = nil

    ActiveRecord::Base.transaction do
      #Returns first in queued state
      loudnessmeasure = LoudnessMeasure.find_by(state: 'queued')
      if(loudnessmeasure.present?)
        loudnessmeasure.updatestate 'processing'
      end
    end

    loudnessmeasure
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

  def filename
    File.basename url
  end

  def filename_plain
    File.basename(url.gsub("%2F","/"))
  end

  def filepath
    uri = URI::parse(url)
    uri.path[0] = ""

    uri.path
  end

  def filepath_plain
    filepath.gsub("%2F","/")
  end

  def bucketname
    s = url.scan /.*\/\/(.*)\.s3.*/
    s.first.first
  end

  def url_plain
    url.gsub("%2F","/")
  end

  def downloadfroms3 (localfile, acceskey, secretkey, default_region)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => acceskey,
      :aws_secret_access_key    => secretkey,
      :region => default_region})

    bucket = connection.directories.get(bucketname)

    #TODO: Add while bexit == false
    open(localfile, 'wb') do |f|
      bucket.files.get(filepath_plain) do |chunk,remaining_bytes,total_bytes|
        #puts "Rem: #{remaining_bytes}, Total: #{total_bytes}"
        f.write chunk
      end
      f.close
    end

  end

end
