module ResqueWeb
  class JobsController < ApplicationController
  
    def destroy
      args = JSON.parse(params[:args])
      destroyed = Resque::Job.destroy(params[:queue], params[:job_class], *args)
      flash[:info] = "#{pluralize(destroyed, 'job')} deleted."
      redirect_to queue_path(params[:queue])
    end

  end
end
