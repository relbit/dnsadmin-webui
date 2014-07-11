class CommitsController < ApplicationController

    before_filter :init, :only => [:edit, :show]

    def index
        @commits = Commit.all(:order => "commits.created DESC")

        respond_to do |format|
            format.html
        end
    end

    def edit
    end

    def update
    end
    
    def show
    end

    def create
    end

    def new
    end

    def destroy
    end

    def diff_data
        @commit = Commit.find(params[:id])
        response = ""
        
        if not @commit.diff_data.nil?
            response = JSON.parse(@commit.diff_data)
        end
        
        respond_to do |format|
            format.json {render :json => response}
            format.html {render :json => response}
        end
    end
    
    protected

    def init
        @commit = Commit.find(params[:id])
        @title = @commit.action
    end
end