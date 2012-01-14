class LeagueStat < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  
  validates_uniqueness_of :user_id, :scope => :league_id
  
  def self.most_active_leagues(limit=3)
    LeagueStat.select('DISTINCT league_id, played').order('played DESC').limit(limit).collect! { |ls| ls.league }
  end
  
  def winning_streak
    return 0 unless last_played_at == last_won_at
    last_lost_at.blank? ? won : matches_since(last_lost_at)
  end
  
  def losing_streak
    return 0 unless last_played_at == last_lost_at
    last_won_at.blank? ? lost : matches_since(last_won_at)
  end
  
  private

  def matches_since(time)
    user.matches.where(["finished_at > ? AND league_id = ?", time, league.id]).count
  end
end
