module ApplicationHelper
    
    def root?
        session[:user].usertype == "root"
    end
    
    def admin?
        ["admin", "root"].include?(session[:user].usertype)
    end
   
    def record_admin?
        ["admin", "root", "record_admin"].include?(session[:user].usertype)
    end
    
    def can_edit_records?(zonefile)
        admin? or zonefile.users.exists?(:id => session[:user].id)
    end
end
