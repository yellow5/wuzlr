require 'spec_helper'

describe MatchPlayer do
  describe 'constants' do
    context 'TEAM_COLORS' do
      it 'returns valid team colors' do
        MatchPlayer::TEAM_COLORS.should eq(%w( red blue ))
      end
    end

    context 'POSITION_RANGE' do
      it 'returns valid range of positions' do
        MatchPlayer::POSITION_RANGE.should eq(0..3)
      end
    end
  end

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
    it { should ensure_inclusion_of(:position).in_range(MatchPlayer::POSITION_RANGE) }
    it { should validate_presence_of(:player) }
    it { should validate_presence_of(:match) }

    context 'team' do
      let(:user) { User.create!(:email => 'user1@email.com', :password => 'asdf1234', :name => 'User 1') }
      let(:league) { League.create!(:name => 'League Name', :user_id => user.id) }
      let(:match) { Match.create!(:league_id => league.id) }
      let(:match_player) { MatchPlayer.new(:position => 0, :player_id => user.id, :match_id => match.id) }
      let(:bad_colors) { %w( green yellow ) }

      it "ensures inclusion of in #{MatchPlayer::TEAM_COLORS.join(',')}" do
        MatchPlayer::TEAM_COLORS.each do |team_color|
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
