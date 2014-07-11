module UsersHelper
    
    def get_user_types
        {"Root" => "root", "Admin" => "admin", "Record admin" => "record_admin"}
    end
    
    def get_user_type(user_type)
        get_user_types.invert[user_type]
    end
end