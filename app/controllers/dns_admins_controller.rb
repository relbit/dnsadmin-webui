class DnsAdminsController < ApplicationController

    before_filter :init, :only => [:edit, :update]

    def index        
        @dnsadmins = DnsAdmin.all(:order => "dns_admins.name ASC")

        respond_to do |format|
            format.html
        end
    end

    def edit
        return if not self.check
    end

    def update
        return if not self.check
        
        respond_to do |format|
            if @dnsadmin.update_attributes(params[:dns_admin])
                format.html  { redirect_to(edit_dns_admin_path(@dnsadmin),
                    :notice => 'DNS admin was successfully updated.') }
            else
                format.html  { render :action => "edit" }
            end
        end
    end

    def create
        return if not self.check
        
        @dnsadmin = DnsAdmin.new(params[:dns_admin])

        respond_to do |format|
            if @dnsadmin.save
                format.html  { redirect_to(edit_dns_admin_path(@dnsadmin),
                    :notice => 'DNS admin was successfully created.') }
                #          format.json  { render :json => @dnsadmin,
                #                        :status => :created, :location => @dnsadmin }
            else
                format.html  { render :action => "new" }
            end
        end
    end

    def new
        return if not self.check
        
        @dnsadmin = DnsAdmin.new
        @dnsadmin.use_ssl = 1

        respond_to do |format|
            format.html
        end
    end

    def destroy
        return if not self.check
        
        @dnsadmin = DnsAdmin.find(params[:id])
        @dnsadmin.destroy

        respond_to do |format|
            format.html { redirect_to dns_admins_url }
        end
    end

    protected

    def init
        @dnsadmin = DnsAdmin.find(params[:id])
        @title = @dnsadmin.name
    end
    
    protected
    
    def check
        if not view_context.admin?
            render :nothing => true
            return false
        end
        true
    end
end