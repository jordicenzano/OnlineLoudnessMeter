S3DirectUpload.config do |c|
  #TODO: Hide config
  #User: loudnessuploader
	c.access_key_id       = CONFIG_ONLINELOUDNESS['loudnessuploader']['key']
	c.secret_access_key   = CONFIG_ONLINELOUDNESS['loudnessuploader']['secret']
	c.bucket 			        = CONFIG_ONLINELOUDNESS['loudnessuploader']['bucket']
 end

## URL Patch
module S3DirectUpload
  module UploadHelper
    class S3Uploader
      def url
        "http#{@options[:ssl] ? 's' : ''}://#{@options[:bucket]}.#{@options[:region]}.amazonaws.com/"
      end
    end
  end
end