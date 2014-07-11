class User < ActiveRecord::Base
    has_many :records
    has_many :zone_files
    #has_and_belongs_to_many :editable_zone_files, :class_name => Zone_File
    has_many :commits
    
    validates :passwd, :presence => true,
                           :confirmation => true,
                           :length => {:within => 6..40},
                           :on => :create
    validates :passwd, :confirmation => true,
                           :length => {:within => 6..40},
                           :allow_blank => true,
                           :on => :update
    
    def passwd
        @passwd
    end
    
    def passwd=(value)
        @passwd = value        
        self.password = Digest::SHA512.hexdigest(@passwd)
    end
    
    def mark_as_deleted
        self.usertype = 'deleted'
        self.save
    end
    
    def self.get_all
        where('usertype != ?', 'deleted').
        order("users.username ASC")
    end
    
    def self.search_by_term(term)
        where('username LIKE ?', "#{term}%").
        where('usertype != ?', 'deleted').
        order("users.username ASC")
    end
end