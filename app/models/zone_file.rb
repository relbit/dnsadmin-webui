class ZoneFile < ActiveRecord::Base  
    has_and_belongs_to_many :dns_admins
    has_and_belongs_to_many :users, :order => "username ASC"
    belongs_to :user
    has_many :commits
    
    validates :origin,  :presence => true
    validates :ttl, :presence => true
    validates :address, :presence => true
    validates :nameserver, :presence => true
    validates :email, :presence => true
    validates :serial_number, :presence => true
    validates :slave_refresh, :presence => true
    validates :slave_retry, :presence => true
    validates :slave_expiration, :presence => true
    validates :max_cache, :presence => true
    
    def self.get_all       
        select('zf.*').
            from('zone_files as zf').
            where('zf.status = 0').
            where('zf.id = (SELECT MAX(zf2.id) FROM zone_files AS zf2 WHERE zf2.group_id = zf.group_id GROUP BY zf2.group_id)').
            order('zf.label ASC, zf.origin ASC')
    end
    
    def self.get_zones_for_user(user_id)
        self.get_all.where('EXISTS(SELECT * FROM `users_zone_files` WHERE `user_id` = ? AND `zone_file_id` = `zf`.`id`)', user_id)        
    end
    
    def self.get_current(group_id)
        select('zf.*').
            from('zone_files as zf').
            where('zf.status = 0').
            where("zf.id = (SELECT MAX(zf2.id) FROM zone_files AS zf2 WHERE zf2.group_id = #{group_id} GROUP BY zf2.group_id)").
            first    
    end
    
    def create_record(data)
        record = Record.new(data)
        record.zone_file_group_id = self.group_id
        record
    end
    
    def inc_sn(save = true)
        time = Time.new.strftime("%Y%m%d")
        sn = self.serial_number.to_s[0, time.length]
        if time == sn
            self.serial_number += 1
        else
            self.serial_number = (time + "01").to_i
        end
        self.save if save
    end
    
    def records
        get_all_records
    end
    
    def get_all_records(with_deleted = false)
        Record.get_all self.group_id, with_deleted
    end
    
    def mark_as_deleted
        self.status = 1
        self.save        
    end
    
    def get_commit_changes
        {:soa => self.get_soa_changes, :records => self.get_records_changes}
    end
    
    def get_soa_changes
        result = {:current => {}, :previous => {}}
            
        if self.dirty?
            result[:current] = JSON.parse(self.to_json)
                
            result[:current][:user] = {
                :username => self.user.username,
                :usertype => self.user.usertype, 
                :id => self.user.id
            }
            
            if not self.first?
                previous = ZoneFile.find(self.previous_id)
                result[:previous] = JSON.parse(previous.to_json)
                
                result[:previous][:user] = {
                    :username => previous.user.username,
                    :usertype => previous.user.usertype, 
                    :id => previous.user.id
                }
            end
        end
        
        result
    end
    
    def get_records_changes
        r = self.get_all_records true
        records = []
        
        r.each do |record|
            hash = JSON.parse(record.to_json)
            
            if record.dirty? and record.status == 0 and record.previous_id > 0
                previous = Record.find(record.previous_id)
                hash[:previous] = JSON.parse(previous.to_json)                    
                hash[:previous][:user] = {
                    :username => previous.user.username,
                    :usertype => previous.user.usertype, 
                    :id => previous.user.id
                }                
            end
            
            hash[:user] = {
                :username => record.user.username,
                :usertype => record.user.usertype, 
                :id => record.user.id
            }
            
            records << hash
        end
        
        records
    end
    
    def dnsa=(list)
        self.dns_admins.clear
        
        list.each { |id| 
            self.dns_admins << DnsAdmin.find(id) if DnsAdmin.exists? id
        }
    end
    
    def slaves_attr=(value, delimiter = ",")
        list = Set.new(value.split(delimiter).collect{ |item| item.strip})
        list.delete ""
         
        self.slaves = list.to_json
    end
    
    def slaves_attr(delimiter = ", ")
        self.slaves.nil? ? "" : JSON.parse(self.slaves).join(delimiter)
    end
    
    def record_admins_attr=(value, delimiter = ",")
        users = Set.new(value.split(delimiter).collect{ |user| user.strip})
        users.delete ""
        
        self.users.clear
        
        users.each do |user|
            u = User.where(:username => user).first
            self.users << u if not u.nil?
        end
    end
    
    def record_admins_attr(delimiter = ", ")
        users = self.users.all.collect { |user| user.username}
        users.join(delimiter)
    end
    
    def commit_required?        
        Record.has_dirty_record(self.group_id) or dirty?
    end
    
    def dirty!
        self.is_dirty = 1
        self
    end
    
    def commit!
        self.is_dirty = 0
        self.save
        
        self.get_all_records(true).each { |record|
            record.commit!
        }
        
        self
    end
    
    def dirty?
        self.is_dirty == 1
    end
    
    def first?
        self.previous_id == 0
    end
    
    def to_compact
        return nil if self.id().nil?
        
        records = []
            
        self.records.each { |record|
            records.push record.to_compact
        }
        
        {
            :origin => self.origin,
            :ttl => self.ttl,
            :soa => {
                :address => self.address,
                :ns => self.nameserver,
                :email => self.email,
                :serialNumber => self.serial_number,
                :slaveRefresh => self.slave_refresh,
                :slaveRetry => self.slave_retry,
                :slaveExpiration => self.slave_expiration,
                :maxCacheTime => self.max_cache
            },
            :slaves => JSON.parse(self.slaves),
            :records => records
        }
    end
    
    def get_created
        Time.parse(self.created.to_s).strftime("%Y-%m-%d %H:%M:%S")
    end
    
end