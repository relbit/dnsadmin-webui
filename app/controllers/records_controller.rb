class RecordsController < ApplicationController
    before_filter :init
    
    def update
        return if not self.check
        
        @record = Record.find(params[:id])
          
        @new_record = @zonefile.create_record(params[:record])
        @new_record.group_id = @record.group_id
        @new_record.user_id = get_user_id          
        
        respond_to do |format|
            if @new_record.save
                @new_record.previous_id = @record.id
                @new_record.order = @record.order             
                @new_record.dirty!
                @new_record.save

                format.js
            else
                format.js
            end
        end        
    end
    
    def create   
        return if not self.check
              
        @record = @zonefile.create_record(params[:record])
        @record.user_id = get_user_id
        @field_id = params[:fieldId] 
                  
        respond_to do |format|
            if @record.save
                @record.group_id = @record.id
                @record.save                          
                format.js
            else                            
                format.js
            end          
        end    
    end
    
    def destroy
        return if not self.check
        
        record = JSON.parse(Record.find(params[:id]).to_json)     
        record.delete("id")
        record.delete("created")
        new_record = Record.new(record)
        new_record.user_id = get_user_id
        new_record.mark_as_deleted
       
        respond_to do |format|
          format.json { head :no_content }
          format.js
        end
    end
    
    protected
    
    def init
        @zonefile = ZoneFile.find params[:zone_file_id]
    end
    
    protected
    
    def check
        if not view_context.can_edit_records? @zonefile
            render :nothing => true
            return false
        end
        true
    end
end