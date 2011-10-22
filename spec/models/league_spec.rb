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

  describe '#table_bias' do
    let(:league) { Fabricate(:league) }

    def do_invoke
      league.table_bias
    end

    it 'returns an array with two elements' do
      do_invoke.class.should eq(Array)
      do_invoke.length.should eq(2)
    end

    it 'finds bias on recorded matches' do
      mock_matches = mock
      league.stubs(:matches).returns(mock_matches)
      mock_matches.expects(:find).with(:all, :conditions => { :state => 'recorded' }).returns([])
      do_invoke
    end

    context 'first index' do
      it 'contains a 10 element array' do
        do_invoke[0].class.should eq(Array)
        do_invoke[0].length.should eq(10)
      end

      context '10 element array elements' do
        it 'contain a 2 element array' do
          (0..9).each do |index|
            do_invoke[0][index].class.should eq(Array)
            do_invoke[0][index].length.should eq(2)
          end
        end

        context 'first index' do
          it 'returns score differential message' do
            (0..9).each do |index|
              do_invoke[0][index][0].should eq("Won by #{index + 1}")
            end
          end
        end

        context 'second index' do
          before do
            (1..10).each do |counter|
              counter.times do
                Fabricate(:match, :league => league, :state => 'recorded', :red_score => 10, :blue_score => (10 - counter))
              end
            end
          end

          it 'returns count of red score victories by score differential' do
            (0..9).each do |index|
              do_invoke[0][index][1].should eq(index + 1)
            end
          end
        end
      end
    end

    context 'second index' do
      it 'contains a 10 element array' do
        do_invoke[1].class.should eq(Array)
        do_invoke[1].length.should eq(10)
      end

      context '10 element array elements' do
        it 'contain a 2 element array' do
          (0..9).each do |index|
            do_invoke[1][index].class.should eq(Array)
            do_invoke[1][index].length.should eq(2)
          end
        end

        context 'first index' do
          it 'returns score differential message' do
            (0..9).each do |index|
              do_invoke[1][index][0].should eq("Won by #{index + 1}")
            end
          end
        end

        context 'second index' do
          before do
            (1..10).each do |counter|
              counter.times do
                Fabricate(:match, :league => league, :state => 'recorded', :blue_score => 10, :red_score => (10 - counter))
              end
            end
          end

          it 'returns count of blue score victories by score differential' do
            (0..9).each do |index|
              do_invoke[1][index][1].should eq(index + 1)
            end
          end
        end
      end
    end
  end

  describe '#add_win' do
    let(:league) { Fabricate(:league) }
    let(:user) { Fabricate(:user) }
    let(:finished_at) { 1.hour.ago }

    def do_invoke
      league.add_win(user, finished_at)
    end

    it 'raises an error without arguments' do
      expect { league.add_win }.should raise_error(ArgumentError, /wrong number of arguments/)
    end

    context 'with existing player stat' do
      let!(:league_stat) { Fabricate(:league_stat, :league => league, :user => user) }

      it 'does not create a new league stat record' do
        expect { do_invoke }.should_not change { league.stats.count }
      end

      it 'increments played count for stat' do
        expect { do_invoke }.should change { league_stat.reload.played }.by(1)
      end

      it 'increments won count for stat' do
        expect { do_invoke }.should change { league_stat.reload.won }.by(1)
      end

      it 'updates win_percent for stat' do
        expect { do_invoke }.should change { league_stat.reload.win_percent }.to(100)
      end

      context 'with finished_at argument' do
        it 'updates last_played_at to received value for stat' do
          expect { do_invoke }.should change { league_stat.reload.last_played_at.to_s }.to(finished_at.to_s)
        end

        it 'updates last_won_at to received value for stat' do
          expect { do_invoke }.should change { league_stat.reload.last_won_at.to_s }.to(finished_at.to_s)
        end
      end

      context 'without finished_at argument' do
        let!(:right_now) { Time.now.utc }

        before { Time.stubs(:now).returns(right_now) }

        it 'updates last_played_at to Time.now for stat' do
          expect { league.add_win(user) }.should change { league_stat.reload.last_played_at.to_s }.to(right_now.to_s)
        end

        it 'updates last_won_at to Time.now for stat' do
          expect { league.add_win(user) }.should change { league_stat.reload.last_won_at.to_s }.to(right_now.to_s)
        end
      end

      context 'stat.winning_streak > stat.longest_winning_streak' do
        before { league_stat.update_attributes!(:longest_winning_streak => 0) }

        it 'updates longest_winning_streak for stat' do
          expect { do_invoke }.should change { league_stat.reload.longest_winning_streak }.to(1)
        end
      end

      context 'stat.winning_streak is not > stat.longest_winning_streak' do
        before { league_stat.update_attributes!(:longest_winning_streak => 10) }

        it 'does not change longest_winning_streak for stat' do
          expect { do_invoke }.should_not change { league_stat.reload.longest_winning_streak }
        end
      end
    end

    context 'without existing player stat' do
      let(:newest_league_stat) { league.stats.last }

      it 'creates a new league stat record for player' do
        expect { do_invoke }.should change { league.stats.count }.by(1)
        newest_league_stat.user.should eq(user)
      end

      it 'assigns played to stat' do
        do_invoke
        newest_league_stat.played.should eq(1)
      end

      it 'assigns won to stat' do
        do_invoke
        newest_league_stat.won.should eq(1)
      end

      it 'assigns win_percent to stat' do
        do_invoke
        newest_league_stat.win_percent.should eq(100)
      end

      context 'with finished_at argument' do
        it 'assigns last_played_at received value to stat' do
          do_invoke
          newest_league_stat.last_played_at.to_s.should eq(finished_at.to_s)
        end

        it 'assigns last_won_at received value to stat' do
          do_invoke
          newest_league_stat.last_won_at.to_s.should eq(finished_at.to_s)
        end
      end

      context 'without finished_at argument' do
        let!(:right_now) { Time.now.utc }

        before { Time.stubs(:now).returns(right_now) }

        it 'assigns last_played_at Time.now to stat' do
          league.add_win(user)
          newest_league_stat.last_played_at.to_s.should eq(right_now.to_s)
        end

        it 'assigns last_won_at Time.now to stat' do
          league.add_win(user)
          newest_league_stat.last_won_at.to_s.should eq(right_now.to_s)
        end
      end

      it 'assigns longest_winning_streak to stat' do
        do_invoke
        newest_league_stat.longest_winning_streak.should eq(1)
      end
    end
  end

  describe '#add_lost' do
    let(:league) { Fabricate(:league) }
    let(:user) { Fabricate(:user) }
    let(:finished_at) { 1.hour.ago }

    def do_invoke
      league.add_lost(user, finished_at)
    end

    it 'raises an error without arguments' do
      expect { league.add_lost }.should raise_error(ArgumentError, /wrong number of arguments/)
    end

    it 'raises an error with one argument' do
      expect { league.add_lost(user) }.should raise_error(ArgumentError, /wrong number of arguments/)
    end

    context 'with existing player stat' do
      let!(:league_stat) { Fabricate(:league_stat, :league => league, :user => user) }

      it 'does not create a new league stat record' do
        expect { do_invoke }.should_not change { league.stats.count }
      end

      it 'increments played count for stat' do
        expect { do_invoke }.should change { league_stat.reload.played }.by(1)
      end

      it 'increments lost count for stat' do
        expect { do_invoke }.should change { league_stat.reload.lost }.by(1)
      end

      it 'updates win_percent for stat' do
        league_stat.update_attributes!(:played => 1, :won => 1, :win_percent => 100)
        expect { do_invoke }.should change { league_stat.reload.win_percent }.to(50)
      end

      it 'updates last_played_at for stat' do
        expect { do_invoke }.should change { league_stat.reload.last_played_at.to_s }.to(finished_at.to_s)
      end

      it 'updates last_lost_at for stat' do
        expect { do_invoke }.should change { league_stat.reload.last_lost_at.to_s }.to(finished_at.to_s)
      end

      context 'stat.losing_streak > stat.longest_losing_streak' do
        before { league_stat.update_attributes!(:longest_losing_streak => 0) }

        it 'updates longest_losing_streak for stat' do
          expect { do_invoke }.should change { league_stat.reload.longest_losing_streak }.to(1)
        end
      end

      context 'stat.losing_streak is not > stat.longest_losing_streak' do
        before { league_stat.update_attributes!(:longest_losing_streak => 10) }

        it 'does not change longest_losing_streak for stat' do
          expect { do_invoke }.should_not change { league_stat.reload.longest_losing_streak }
        end
      end
    end

    context 'without existing player stat' do
      let(:newest_league_stat) { league.stats.last }

      it 'creates a new league stat record for player' do
        expect { do_invoke }.should change { league.stats.count }.by(1)
        newest_league_stat.user.should eq(user)
      end

      it 'assigns played to stat' do
        do_invoke
        newest_league_stat.played.should eq(1)
      end

      it 'assigns lost to stat' do
        do_invoke
        newest_league_stat.lost.should eq(1)
      end

      it 'assigns win_percent to stat' do
        do_invoke
        newest_league_stat.win_percent.should eq(0)
      end

      it 'assigns last_played_at received value to stat' do
        do_invoke
        newest_league_stat.last_played_at.to_s.should eq(finished_at.to_s)
      end

      it 'assigns last_lost_at received value to stat' do
        do_invoke
        newest_league_stat.last_lost_at.to_s.should eq(finished_at.to_s)
      end

      it 'assigns longest_losing_streak to stat' do
        do_invoke
        newest_league_stat.longest_losing_streak.should eq(1)
      end
    end
  end
end
