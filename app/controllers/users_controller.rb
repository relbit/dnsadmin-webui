class UsersController < ApplicationController

    before_filter :init, :only => [:edit, :update]

    def index
        @users = User.get_all

        respond_to do |format|
            format.html
        end
    end

    def edit
    end

    def update
        respond_to do |format|
            if @user.update_attributes(params[:user])
                format.html  { redirect_to(edit_user_path(@user),
                    :notice => 'User was successfully updated.') }
            else
                format.html  { render :action => "edit" }
            end
        end
    end

    def create
        @user = User.new(params[:user])

        respond_to do |format|
            if @user.save
                format.html  { redirect_to(edit_user_path(@user),
                    :notice => 'User was successfully created.') }
                #          format.json  { render :json => @dnsadmin,
                #                        :status => :created, :location => @dnsadmin }
            else
                format.html  { render :action => "new" }
            end
        end
    end

    def new
        @user = User.new

        respond_to do |format|
            format.html
        end
    end

    def destroy
        @user = User.find(params[:id])
        @user.mark_as_deleted

        respond_to do |format|
            format.html { redirect_to users_url }
        end
    end

    protected

    def init
        @user = User.find(params[:id])
        @title = @user.username
    end
end