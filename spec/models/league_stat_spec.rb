require 'spec_helper'

describe LeagueStat do
  describe 'attributes' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:league_id).of_type(:integer) }
    it { should have_db_column(:played).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:won).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:lost).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:win_percent).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:last_played_at).of_type(:datetime) }
    it { should have_db_column(:last_won_at).of_type(:datetime) }
    it { should have_db_column(:last_lost_at).of_type(:datetime) }
    it { should have_db_column(:longest_winning_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:longest_losing_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:last_on_top_at).of_type(:datetime) }
    it { should have_db_column(:last_on_bottom_at).of_type(:datetime) }
    it { should have_db_column(:longest_on_top_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:longest_on_bottom_streak).of_type(:integer).with_options(:default => 0) }
  end

  describe 'associations' do
    it { should belong_to(:league) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    let!(:league_stat) { Fabricate(:league_stat) }

    subject { league_stat }

    it { should validate_uniqueness_of(:user_id).scoped_to(:league_id) }
  end

  describe '.most_active_leagues' do
    let(:league1) { Fabricate(:league) }
    let(:league2) { Fabricate(:league) }
    let(:league3) { Fabricate(:league) }
    let!(:league_stat1) { Fabricate(:league_stat, :league => league1, :played => 1) }
    let!(:league_stat2) { Fabricate(:league_stat, :league => league2, :played => 2) }
    let!(:league_stat3) { Fabricate(:league_stat, :league => league3, :played => 3) }
    let(:expected_league_results) { [ league3, league2, league1 ] }

    def do_invoke
      LeagueStat.most_active_leagues
    end

    it 'defaults to three records' do
      do_invoke.count.should eq(3)
    end

    it 'orders by played desc' do
      do_invoke.should eq(expected_league_results)
    end

    it 'returns distinct leagues via league_id, played' do
      user         = Fabricate(:user)
      league_stat4 = Fabricate(:league_stat, :user => user, :league => league3, :played => 3)
      do_invoke.should eq(expected_league_results)

      league_stat4.update_attributes!(:played => 4)
      do_invoke.should eq([ league3, league3, league2 ])
    end

    it 'limits by received limit parameter' do
      LeagueStat.most_active_leagues(2).count.should eq(2)
    end

    it 'returns an empty array if none are found' do
      LeagueStat.destroy_all
      do_invoke.should eq([])
    end
  end

  describe '#winning_streak' do
    context 'last_played_at does not equal last_won_at' do
      let(:league_stat) do
        Fabricate(:league_stat, :last_played_at => Time.now, :last_won_at => 1.day.ago)
      end

      it 'returns 0' do
        league_stat.winning_streak.should eq(0)
      end
    end

    context 'last_played_at equals last_won_at' do
      let!(:played_at) { Time.now }

      context 'last_lost_at is blank' do
        let(:league_stat) do
          Fabricate(
            :league_stat,
            :last_played_at => played_at,
            :last_won_at    => played_at,
            :last_lost_at   => nil,
            :won            => 3
          )
        end

        it 'returns value of won' do
          league_stat.winning_streak.should eq(league_stat.won)
        end
      end

      context 'last_lost_at is not blank' do
        let!(:user) { Fabricate(:user) }
        let!(:league) { Fabricate(:league, :user => user) }
        let!(:another_league) { Fabricate(:league, :user => user) }
        let(:league_stat) do
          Fabricate(
            :league_stat,
            :user           => user,
            :league         => league,
            :last_played_at => played_at,
            :last_won_at    => played_at,
            :last_lost_at   => 1.month.ago,
            :won            => 3
          )
        end

        def generate_matches_for(opts={})
          options = { :finished_at => 2.weeks.ago }.merge(opts)
          2.times do
            match = Fabricate(:match, :finished_at => 2.weeks.ago, :league => options[:league])
            Fabricate(:match_player, :player => options[:user], :match => match)
          end
        end

        before do
          generate_matches_for(:user => user, :league => league)
          generate_matches_for(:user => user, :league => another_league)
        end

        it 'returns league matches since last_lost_at' do
          league_stat.winning_streak.should eq(2)
        end
      end
    end
  end
end
