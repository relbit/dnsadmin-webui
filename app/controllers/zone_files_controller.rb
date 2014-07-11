class ZoneFilesController < ApplicationController

    before_filter :init, :only => [:edit, :update]
        
    def index
        if view_context.admin?
            @zonefiles = ZoneFile.get_all
        else
            @zonefiles = ZoneFile.get_zones_for_user(session[:user].id)
        end
        
        respond_to do |format|
            format.html
            format.json  { render :json => @zonefiles }
        end
    end

    def edit
        latest_zonefile = ZoneFile.get_current(@zonefile.group_id)
        
        if latest_zonefile.id != @zonefile.id
            redirect_to({:action => "edit", :controller => "zone_files", :id => latest_zonefile.id})
        end
    end

    def update
        return if not self.check
        #abort @zonefile.inspect
        
        params[:zone_file][:origin] = @zonefile.origin
        
        @next_zonefile = ZoneFile.new(params[:zone_file])
        @next_zonefile.previous_id = @zonefile.id
        @next_zonefile.user_id = get_user_id

        respond_to do |format|
            if @next_zonefile.save
                @next_zonefile.dirty!
                #@next_zonefile.inc_sn false
                @next_zonefile.save
                format.html  { redirect_to({:action => "edit", :controller => "zone_files", :id => @next_zonefile.id},
                    :notice => 'Zone file was successfully updated.')}
            else
                format.html  { render :action => "edit", :locals => {
                        :notice => 'Zone file cannot be saved - there are errors.', :notice_class => "error"}}
            end
        end
    end

    def create   
        return if not self.check   
        @zonefile = ZoneFile.new(params[:zone_file])
        @zonefile.user_id = get_user_id
        @dnsadmins = DnsAdmin.all

        respond_to do |format|
            if @zonefile.save
                @zonefile.group_id = @zonefile.id
                @zonefile.save
                
                format.html  { redirect_to({:action => "edit", :controller => "zone_files", :id => @zonefile.id},
                    :notice => 'Zone file was successfully created.') }
            else
                format.html  { render :action => "new" }
            end
        end
    end

    def new
        return if not self.check
        
        @zonefile = ZoneFile.new({
            :origin => "domain.",
            :ttl => "1H",
            :address => "@",
            :nameserver => "ns1",
            :email => "admin@example.com.",
            :serial_number => Time.new.strftime("%Y%m%d") + "01",
            :slave_refresh => "1D",
            :slave_retry => "2H",
            :slave_expiration => "4W",
            :max_cache => "1H"
        })

        @dnsadmins = DnsAdmin.all
        @new_record = Record.new

        respond_to do |format|
            format.html
        end
    end

    def record_admins
        users = User.search_by_term params[:term]
        
        response = []
        
        users.each do |user|
            response << {
                :id => user.username,
                :label => user.username,
                :value => user.username
            }
        end
        
        respond_to do |format|
            format.json { render :json => response }
        end
    end

    def slave_addresses
        addresses = Set.new
        term = params[:term]
        
        ZoneFile.all.each { |zf|
            addresses.merge(zf.slaves.nil? ? [] : JSON.parse(zf.slaves).collect{|a| (term.nil? or (a.length >= term.length and a[0, term.length] == term)) ? a : ""})
        }
        
        addresses.delete ""

        respond_to do |format|
            format.json { render :json => addresses }
        end
    end
        
    def destroy     
        return if not self.check
        
        @zonefile = ZoneFile.find(params[:id])
        @zonefile = ZoneFile.get_current(@zonefile.group_id)
            
        success, report = delete_zone(@zonefile)
        @zonefile.mark_as_deleted if success

        respond_to do |format|
            if success
                format.html  { redirect_to zone_files_url, :notice => report}
            else
                format.html  { redirect_to zone_files_url, :alert => report}
            end
        end
    end

    def commit
        @zonefile = ZoneFile.find(params[:id])

        # commit to masters
        success, report = save_zone(@zonefile)

        @zonefile.commit! if success
        
        respond_to do |format|
            if success
                format.html  { redirect_to edit_zone_file_path(@zonefile),
                    :notice => report}
            else
                format.html  { redirect_to edit_zone_file_path(@zonefile),
                    :alert => report}
            end
        end
    end
    
    def changes
        @zonefile = ZoneFile.find(params[:id])
        
        response = @zonefile.get_commit_changes
            
        respond_to do |format|
            format.html {render :json => response}
            format.json {render :json => response}
        end
    end

    def reorder
        zonefile = ZoneFile.find params[:id]
        
        if view_context.can_edit_records? zonefile
            i = 1;
            params[:records].each { |record_id|
                Record.find(record_id).set_order(i)
                i += 1
            }
        end

        respond_to do |format|
            format.json { head :no_content }
        end
    end

    protected

    def init
        @zonefile = ZoneFile.find(params[:id])
        @dnsadmins = DnsAdmin.all
        @new_record = Record.new
        @title = @zonefile.origin
        @title += " (#{@zonefile.label})" if !@zonefile.label.nil? and !@zonefile.label.empty?
    end
    
    protected
    
    def check
        if not view_context.admin?
            render :nothing => true
            return false
        end
        true
    end

    protected

    def save_zone(zonefile)
        
        zonefile.inc_sn
        
        commit = zonefile.commits.create({:user_id => get_user_id})
        
        zone_data = zonefile.to_compact.to_json    
        zone = CGI.escape(zone_data)
        
        commit.action = 'save_zone'
        commit.request = zone_data
        commit.diff_data = zonefile.get_commit_changes.to_json

        all_success = true
        output = ""

        zonefile.dns_admins.each { |adm|
            response = `#{adm.get_save_curl(zone)}` ; success = $?.success?
            msg = get_msg response
            all_success = (all_success and (msg == "OK"))
            output += "#{adm.name} => #{msg}, "
        }

        output = output[0, output.length-2]
        output = (not output.nil? and output.length > 0) ? output : 'none'
        all_status = all_success ? 'Success' : 'Failure'
        all_msg = "Commit report: #{all_status}, details: #{(output.length > 0) ? output : 'none'}"
        
        commit.result = (all_success) ? 1 : 0
        commit.response = all_msg
        commit.save
        
        all_msg += ", <a href=\"#{commit_path(commit)}\">Full report</a>"
        
        return all_success, all_msg
    end

    protected

    def delete_zone(zonefile)
        $zone_not_found = 6
        
        commit = zonefile.commits.create({:user_id => get_user_id})
        
        all_success = true
        output = ""

        commit.action = 'delete_zone'
        
        zonefile.dns_admins.each { |adm|
            response = `#{adm.get_delete_curl(zonefile.origin)}` ; success = $?.success?
            msg = get_msg response
            err_code = get_err_code response
            all_success = (all_success and (msg == "OK" || err_code == $zone_not_found))
            output += "#{adm.name} => #{msg}, "
        }

        output = output[0, output.length-2]
        output = (not output.nil? and output.length > 0) ? output : 'none'
        all_status = all_success ? 'Success' : 'Failure'
        all_msg = "Deleting zone report: #{all_status}, details: #{output}"
        
        commit.result = (all_success) ? 1 : 0
        commit.response = all_msg
        commit.save
        
        all_msg += ", <a href=\"#{commit_path(commit)}\">Full report</a>"
        
        return all_success, all_msg
    end

    protected

    def get_msg(response)
        msg = ""

        begin
            json = JSON.parse response
            if json['errorCode'].to_s != "0"
                msg = "Error #{json["errorCode"]}: " + json['message']
            else
                msg = "OK"
            end
        rescue
            msg = "Cannot parse response (or is offline)"
        end

        msg
    end
    
    protected
    
    def get_err_code(response)
        err_code = -1
        begin
            json = JSON.parse response
            err_code = json['errorCode'].to_i
        rescue
            err_code = -1
        end
        
        err_code        
    end
end