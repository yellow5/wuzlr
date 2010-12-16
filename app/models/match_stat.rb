class MatchStat < ActiveRecord::Base
  
  belongs_to :match
  belongs_to :user
  
  scope :won,        :conditions => {:won => true  }
  scope :lost,       :conditions => {:won => false }

end
