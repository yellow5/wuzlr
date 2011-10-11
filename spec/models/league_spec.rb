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

  describe '#matches_per_day' do
    let(:match_date1) { 1.month.ago }
    let(:match_date2) { 2.months.ago }
    let(:match_date3) { 3.months.ago }
    let(:league) { Fabricate(:league) }
    let(:expected_match_date1_result) { [match_date1.strftime('%Y %b %d'), 2] }
    let(:expected_match_date2_result) { [match_date2.strftime('%Y %b %d'), 4] }
    let(:expected_match_date3_result) { [match_date3.strftime('%Y %b %d'), 3] }
    let(:expected_ordered_results) do
      [expected_match_date3_result, expected_match_date2_result, expected_match_date1_result]
    end

    before do
      2.times { Fabricate(:match, :league => league, :started_at => match_date1) }
      4.times { Fabricate(:match, :league => league, :started_at => match_date2) }
      3.times { Fabricate(:match, :league => league, :started_at => match_date3) }
    end

    it 'counts the number of matches per day by formatted started_at' do
      league.matches_per_day.should include(expected_match_date1_result)
      league.matches_per_day.should include(expected_match_date2_result)
      league.matches_per_day.should include(expected_match_date3_result)
    end

    it 'sorts the results oldest match date to newest match date' do
      league.matches_per_day.should eq(expected_ordered_results)
    end
  end
end
