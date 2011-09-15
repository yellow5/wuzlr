require 'spec_helper'

describe MatchPlayer do
  describe 'attributes' do
    it { should have_db_column(:team).of_type(:string) }
    it { should have_db_column(:position).of_type(:integer) }
    it { should have_db_column(:match_id).of_type(:integer) }
    it { should have_db_column(:player_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { should belong_to(:player) }
    it { should belong_to(:match) }
  end

  describe 'validations' do
    it { should ensure_inclusion_of(:position).in_range(0..3) }
    it { should validate_presence_of(:player) }
    it { should validate_presence_of(:match) }

    context 'team' do
      let(:user) { User.create!(:email => 'user1@email.com', :password => 'asdf1234', :name => 'User 1') }
      let(:league) { League.create!(:name => 'League Name', :user_id => user.id) }
      let(:match) { Match.create!(:league_id => league.id) }
      let(:match_player) { MatchPlayer.new(:position => 0, :player_id => user.id, :match_id => match.id) }
      let(:team_colors) { %w( red blue ) }
      let(:bad_colors) { %w( green yellow ) }

      it 'ensures inclusion of in red,blue' do
        team_colors.each do |team_color|
          match_player.team = team_color
          match_player.should be_valid
        end
        bad_colors.each do |bad_color|
          match_player.team = bad_color
          match_player.should have(1).error_on(:team)
        end
      end
    end
  end
end
