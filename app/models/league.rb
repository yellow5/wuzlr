class League < ActiveRecord::Base
  include DbDateFormat
  
  belongs_to :user
  has_many :matches
  has_many :league_players
  has_many :players, :through => :league_players
  has_many :stats, :class_name => "LeagueStat"  
  
  validates_presence_of :name
  validates_presence_of :user, :on => :create
  
  def add_player(user)
    league_players.create(:player_id => user.id) unless players.include?(user)
  end
  
  def owner?(user)
    self.user == user
  end
  
  def member_of?(user)
    self.players.include?(user)
  end
  
  def matches_per_day
    results = matches.group(db_date_format(:field => 'started_at', :format => 'YYYY Mon DD')).count
    results.map{|k,v| [DateTime.strptime(k,'%Y %b %d'),v] }.sort_by{|e| e[0]}
  end
  
  def table_bias
    red_score  = Array.new(10){|i| "Won by #{i+1}"}.map{|e| [e,0]}
    blue_score = Array.new(10){|i| "Won by #{i+1}"}.map{|e| [e,0]}
    
    matches.where(:state => 'recorded').each do |r|
      case r.winner
      when "blue"
        blue_score[r.score_difference - 1][1] += 1
      when "red"
        red_score[r.score_difference - 1][1] += 1
      end
    end
    [red_score, blue_score]
  end
  
  def add_win(player,finished_at = Time.now)
    stat = stats.where(:user_id => player).first || stats.new(:user_id => player.id)
    stat.increment :played
    stat.increment :won
    stat.win_percent            = ((stat.won / stat.played.to_f) * 100).to_i
    stat.last_played_at         = finished_at
    stat.last_won_at            = finished_at
    
    current_streak              = stat.winning_streak
    stat.longest_winning_streak = current_streak if current_streak > stat.longest_winning_streak
    stat.save!
  end
  
  def add_lost(player, finished_at)
    stat = stats.where(:user_id => player).first || stats.new(:user_id => player.id)
    stat.increment :played
    stat.increment :lost
    stat.win_percent           = ((stat.won / stat.played.to_f) * 100).to_i
    stat.last_played_at        = finished_at
    stat.last_lost_at          = finished_at
    
    current_streak             = stat.losing_streak
    stat.longest_losing_streak = current_streak if current_streak > stat.longest_losing_streak
    stat.save!
  end
end
