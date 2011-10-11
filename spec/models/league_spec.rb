require 'spec_helper'

describe League do
  describe 'mixins' do
    subject { League.included_modules }

    it { should include(DbDateFormat) }
  end

  describe 'attributes' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:description).of_type(:text) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:user_id).of_type(:integer) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:matches) }
    it { should have_many(:league_players) }
    it { should have_many(:players).through(:league_players) }
    it { should have_many(:stats) }
  end

  describe 'validations' do
    context 'new record' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:user) }
    end

    context 'existing record' do
      let!(:league) { Fabricate(:league) }

      subject { league }

      it { should_not validate_presence_of(:user) }
    end
  end

  describe '#add_player' do
    let(:user) { Fabricate(:user) }
    let(:league) { Fabricate(:league) }

    context 'received user is not part of league' do
      before do
        LeaguePlayer.delete_all
      end

      it 'creates a new league player with user' do
        expect { league.add_player(user) }.should change(LeaguePlayer, :count).by(1)
        league.players.should include(user)
      end
    end

    context 'received user is part of league' do
      before do
        Fabricate(:league_player, :league => league, :player => user)
      end

      it 'does not create a new league player with user' do
        expect { league.add_player(user) }.should_not change(LeaguePlayer, :count)
      end
    end
  end

  describe '#owner?' do
    let!(:user) { Fabricate(:user) }
    let!(:another_user) { Fabricate(:user) }
    let!(:league) { Fabricate(:league, :user => user) }

    it 'returns true if user is the received user' do
      league.owner?(user).should be_true
    end

    it 'returns false if user is not the received user' do
      league.owner?(another_user).should be_false
    end
  end

  describe '#member_of?' do
    let(:user) { Fabricate(:user) }
    let(:league) { Fabricate(:league) }

    it 'returns true if user is a league player' do
      Fabricate(:league_player, :league => league, :player => user)
      league.member_of?(user).should be_true
    end

    it 'returns false if user is not a league player' do
      LeaguePlayer.delete_all
      league.member_of?(user).should be_false
    end
  end
end
