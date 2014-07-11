class Commit < ActiveRecord::Base
    belongs_to :user
    belongs_to :zone_file
    
    def get_created
        Time.parse(self.created.to_s).strftime("%Y-%m-%d %H:%M:%S")
    end
end