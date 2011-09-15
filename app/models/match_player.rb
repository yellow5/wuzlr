class MatchPlayer < ActiveRecord::Base
  belongs_to :player, :class_name => "User"
  belongs_to :match

  validates_inclusion_of :team,     :in => %w( red blue )
  validates_inclusion_of :position, :in => 0..3
  validates_presence_of  :player
  validates_presence_of  :match
end
