class MatchPlayer < ActiveRecord::Base
  TEAM_COLORS    = %w( red blue )
  POSITION_RANGE = 0..3

  belongs_to :player, :class_name => "User"
  belongs_to :match

  validates_inclusion_of :team,     :in => TEAM_COLORS
  validates_inclusion_of :position, :in => POSITION_RANGE
  validates_presence_of  :player
  validates_presence_of  :match
end
