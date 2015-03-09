class LoudnessmeasuresController < ApplicationController

	@loudnessmeasure = nil
	@loudnessmeasures = nil

	def new
		@loudnessmeasure = LoudnessMeasure.new()
	end
	
	def create
  		@loudnessmeasure = LoudnessMeasure.new(loudnessmeasure_params_to_db)
 
  		if @loudnessmeasure.save
			render :action => 'show', :id => @loudnessmeasure.id
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
		params.require(:loudnessmeasure).permit(:name, :obs, :url)

		{:state => 'queued', :name => params[:loudnessmeasure][:name], :obs => params[:loudnessmeasure][:obs], :url => params[:loudnessmeasure][:url], :user_id => current_user.id}
	end

end
