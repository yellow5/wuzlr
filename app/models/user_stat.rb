class UserStat < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :other_user, :class_name => "User"
  
  scope :opponents, :conditions => {:relation => "opponent"}
  scope :allies,    :conditions => {:relation => "ally"    }
  scope :won,       :conditions => {:won      => true      }
  scope :lost,      :conditions => {:won      => false     }
  
end
