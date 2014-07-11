class DnsAdmin < ActiveRecord::Base

    $command = "curl -k -s --connect-timeout 5 -X %s --user %s:%s %s %s/%s"
        
    has_and_belongs_to_many :zone_files
    
    validates :name,  :presence => true
    validates :address, :presence => true
    validates :user, :presence => true
    validates :password, :presence => true
    
    def get_save_curl(zonefile, reload = true)
        return nil if self.id.nil?
        
        protocol = self.use_ssl? ? "https://" : "http://";
        method = "PUT"
        route = "save_zone"
        
        data_zonefile = " -d zonefile=#{zonefile} "
        data_reload = reload ? " -d reload=true " : " "
        data = "#{data_zonefile} #{data_reload}"
        
        address = "#{protocol}#{self.address}"
        
        $command % [method, self.user, self.password, data, address, route]
    end
    
    def get_delete_curl(zonefile)
        return nil if self.id.nil?
        
        protocol = self.use_ssl? ? "https://" : "http://";
        method = "DELETE"
        route = "delete_zone"
        
        data = " -d zonefile=#{zonefile} "
        
        address = "#{protocol}#{self.address}"
        
        $command % [method, self.user, self.password, data, address, route]
    end
    
    def use_ssl?
        (self.use_ssl == 1)
    end
end