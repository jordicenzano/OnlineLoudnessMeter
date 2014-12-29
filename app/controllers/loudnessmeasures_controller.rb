class LoudnessmeasuresController < ApplicationController

	@loudnessmeasure = nil
	@loudnessmeasures = nil

	@uploadthread = nil

	def new
		@loudnessmeasure = LoudnessMeasure.new()
	end
	
	def create
  		@loudnessmeasure = LoudnessMeasure.new(loudnessmeasure_params_to_db)
 
  		if @loudnessmeasure.save
			render :action => 'show', :id => @loudnessmeasure.id

			@loudnessmeasure.upload loudnessmeasure_params_uploadfile
		else
			render 'new'
		end 
 	end
	
	def show
		#TODO: improve (if null?)
  		@loudnessmeasure = LoudnessMeasure.where("id = #{params[:id]} AND user_id = #{current_user.id}").first
 	end

	def index
		#TODO: improve
  		@loudnessmeasures = LoudnessMeasure.where("user_id = #{current_user.id}")
	end

private 

 	def loudnessmeasure_params_to_db
    	params.require(:loudnessmeasure).permit(:name, :obs, :originalfilename)	

  		ret = {:state => 'uploading', :name => params[:loudnessmeasure][:name], :obs => params[:loudnessmeasure][:obs], :user_id => current_user.id}
  		if loudnessmeasure_params_uploadfile
  			ret[:originalfilename] = loudnessmeasure_params_uploadfile.original_filename
  		end

  		ret
	end

  	def loudnessmeasure_params_uploadfile
  		params[:loudnessmeasure][:originalfilename]
  	end

end
