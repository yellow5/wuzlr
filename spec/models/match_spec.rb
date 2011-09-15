require 'spec_helper'

describe Match do
  describe 'attributes' do
    it { should have_db_column(:started_at).of_type(:datetime) }
    it { should have_db_column(:finished_at).of_type(:datetime) }
    it { should have_db_column(:red_score).of_type(:integer) }
    it { should have_db_column(:blue_score).of_type(:integer) }
    it { should have_db_column(:league_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:state).of_type(:string) }
  end

  describe 'associations' do
    it { should belong_to(:league) }
    it { should have_many(:match_players) }
    it { should have_many(:players).through(:match_players) }
    it { should have_many(:red_players).through(:match_players) }
    it { should have_many(:blue_players).through(:match_players) }
    it { should have_many(:stats) }

    context 'team players' do
      let(:red_user) { User.create!(:email => 'user1@email.com', :password => 'asdf1234', :name => 'User 1') }
      let(:blue_user) { User.create!(:email => 'user2@email.com', :password => 'asdf1234', :name => 'User 2') }
      let(:league) { League.create!(:name => 'League Name', :user_id => red_user.id) }
      let!(:match) { Match.create!(:league_id => league.id) }
      let!(:red_match_player) { MatchPlayer.create!(:match_id => match.id, :team => 'red', :player_id => red_user.id, :position => 0) }
      let!(:blue_match_player) { MatchPlayer.create!(:match_id => match.id, :team => 'blue', :player_id => blue_user.id, :position => 0) }

      subject { match }

      context 'red_players' do
        let(:expected_match_players) { [ red_user ] }

        it 'only returns match_players on the red team' do
          subject.red_players.should eq(expected_match_players)
        end
      end

      context 'blue_players' do
        let(:expected_match_players) { [ blue_user ] }

        it 'only returns match_players on the blue team' do
          subject.blue_players.should eq(expected_match_players)
        end
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:league) }
  end
end
