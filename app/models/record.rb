class Record < ActiveRecord::Base
    belongs_to :zone_file
    belongs_to :user
    
    validates :rtype,  :presence => true
    validates :data,  :presence => true
    
    def self.get_all(group_id, with_deleted = false)
        records = select('r.*').
            from('records as r').
            where("r.zone_file_group_id = ?", group_id).
            where('r.id = (SELECT MAX(r2.id) FROM records AS r2 WHERE r2.group_id = r.group_id GROUP BY r2.group_id)').
            order('r.order ASC, r.group_id ASC')
            
        with_deleted ? records : records.where('r.status = 0')       
    end
    
    def self.has_dirty_record(group_id)
        count = select('COUNT(r.*)').
            from('records as r').
            where('r.dirty = ?', 1).
            where("r.zone_file_group_id = ?", group_id).
            where('r.id = (SELECT MAX(r2.id) FROM records AS r2 WHERE r2.group_id = r.group_id GROUP BY r2.group_id)').first
        (count > 0)       
    end
    
    def mark_as_deleted
        self.status = 1
        self.dirty!
        self.save        
    end
    
    def dirty!
        self.is_dirty = 1
        self
    end
    
    def commit!
        self.is_dirty = 0
        self.save
        self
    end
    
    def dirty?
        self.is_dirty == 1
    end
    
    def set_order(i)
        self.order = i
        self.save
        self 
    end
    
    def to_compact
        return nil if self.id.nil?
        
        {
            :name => self.name,
            :ttl => self.ttl,
            :rtype => self.rtype,
            :address => self.data
        }
    end
    
    def get_created
        Time.parse(self.created.to_s).strftime("%Y-%m-%d %H:%M:%S")
    end
end