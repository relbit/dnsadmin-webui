module AuthHelper
    
    
    
    
    
    #
    # This method returns User, whose credentials matched given username and 
    # password. If no user was found, nil is returned.
    #
    #
    def user_auth(username, password)
        User.where(:username => username, :password => Digest::SHA512.hexdigest(password)).first
    end
    
    
    
    
    
    
    
    #
    # Adds user to DB.
    # usertype must be one of [root, admin, record_admin]
    # password mustn't be empty.
    #
    # @return boolean
    #
    protected
    def add_user(id, username, usertype)
        user = User.new({:id => id, :username => username, :usertype => usertype, :passwd => "nothing"})
        user.id = id
        user.save
    end
    
    #
    # Checks for user existence by username
    #
    # @return boolean
    #
    protected
    def user_exists(username)
        not User.where(:username => username).first.nil?
    end

    #
    # Checks for user existence by user id
    #
    # @return boolean
    #
    protected
    def user_exists_by_id(id)
        begin
            not User.find(id).nil?
        rescue
            false
        end
    end
end
