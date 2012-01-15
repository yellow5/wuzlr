require 'spec_helper'

describe User do
  describe 'mixins' do
    subject { User.included_modules }

    it { should include(DbDateFormat) }
    it { should include(Devise::Models::Authenticatable) }
    it { should include(Devise::Models::Recoverable) }
    it { should include(Devise::Models::Registerable) }
    it { should include(Devise::Models::Rememberable) }
    it { should include(Devise::Models::Trackable) }
    it { should include(Devise::Models::Validatable) }
  end

  describe 'attributes' do
    it { should have_db_column(:email).of_type(:string).with_options(:default => '', :null => false) }
    it { should have_db_column(:encrypted_password).of_type(:string).with_options(:limit => 128, :default => '', :null => false) }
    it { should have_db_column(:reset_password_token).of_type(:string) }
    it { should have_db_column(:remember_token).of_type(:string) }
    it { should have_db_column(:remember_created_at).of_type(:datetime) }
    it { should have_db_column(:sign_in_count).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:current_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:last_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:current_sign_in_ip).of_type(:string) }
    it { should have_db_column(:last_sign_in_ip).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:played).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:won).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:lost).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:last_played_at).of_type(:datetime) }
    it { should have_db_column(:last_won_at).of_type(:datetime) }
    it { should have_db_column(:last_lost_at).of_type(:datetime) }
    it { should have_db_column(:longest_winning_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:longest_losing_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:win_loss_percentage).of_type(:float).with_options(:default => 0.0) }
  end

  describe 'indexes' do
    it { should have_db_index(:email).unique(true) }
    it { should have_db_index(:reset_password_token).unique(true) }
  end

  describe 'associations' do
    it { should have_many(:league_players) }
    it { should have_many(:leagues).through(:league_players) }
    it { should have_many(:match_players) }
    it { should have_many(:matches).through(:match_players) }
    it { should have_many(:stats) }
    it { should have_many(:match_stats) }
    it { should have_many(:league_stats) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'accessible attributes' do
    subject { User.accessible_attributes }

    it { should include(:name) }
    it { should include(:email) }
    it { should include(:password) }
    it { should include(:password_confirmation) }
    it { should include(:remember_me) }
  end

  context 'before save' do
    context 'email is mhaskins@changehealthcare.com' do
      let(:user) { Fabricate.build(:user, :email => 'mhaskins@changehealthcare.com') }
      let(:sprinkles) { 'Michael "Sprinkles" Haskins' }

      it 'changes name to Michael "Sprinkles" Haskins' do
        expect { user.save! }.should change { user.name }.to(sprinkles)

        user.name = 'Michael Haskins'
        expect { user.save! }.should change { user.name }.to(sprinkles)

        user.name = 'Trololo'
        expect { user.save! }.should change { user.name }.to(sprinkles)
      end
    end
  end

  describe '#win_p' do
    let(:user) { User.new }

    context 'played is > 0' do
      before { user.played = 10 }

      it 'returns the percentage of games won' do
        [1, 4, 7].each do |won|
          user.won = won
          user.win_p.should eq(won * 10)
        end
      end
    end

    context 'played is not > 0' do
      it 'returns 0' do
        user.won = 1
        [0, -1].each do |played|
          user.played = played
          user.win_p.should eq(0)
        end
      end
    end
  end

  describe '#lose_p' do
    let(:user) { User.new }

    context 'played is > 0' do
      before { user.played = 10 }

      it 'returns the percentage of games lost' do
        [1, 4, 7].each do |lost|
          user.lost = lost
          user.lose_p.should eq(lost * 10)
        end
      end
    end

    context 'played is not > 0' do
      it 'returns 0' do
        user.lost = 1
        [0, -1].each do |played|
          user.played = played
          user.lose_p.should eq(0)
        end
      end
    end
  end

  describe '#matches_per_day' do
    let!(:user) { Fabricate(:user) }
    let(:one_month_ago) { 1.month.ago }
    let(:two_months_ago) { 2.months.ago }
    let(:three_months_ago) { 3.months.ago }
    let!(:match1) { Fabricate(:match, :started_at => one_month_ago) }
    let!(:match2) { Fabricate(:match, :started_at => two_months_ago) }
    let!(:match3) { Fabricate(:match, :started_at => two_months_ago) }
    let!(:match4) { Fabricate(:match, :started_at => two_months_ago) }
    let!(:match5) { Fabricate(:match, :started_at => three_months_ago) }
    let!(:match6) { Fabricate(:match, :started_at => three_months_ago) }
    let!(:match_player1) { Fabricate(:match_player, :match => match1, :player => user) }
    let!(:match_player2) { Fabricate(:match_player, :match => match2, :player => user) }
    let!(:match_player3) { Fabricate(:match_player, :match => match3, :player => user) }
    let!(:match_player4) { Fabricate(:match_player, :match => match4, :player => user) }
    let!(:match_player5) { Fabricate(:match_player, :match => match5, :player => user) }
    let!(:match_player6) { Fabricate(:match_player, :match => match6, :player => user) }
    let(:expected_results) do
      [
        [ three_months_ago.beginning_of_day, 2 ],
        [ two_months_ago.beginning_of_day, 3 ],
        [ one_month_ago.beginning_of_day, 1 ]
      ]
    end

    subject { user.matches_per_day }

    it 'returns count of games per day based on started_at ordered by date' do
      subject.should eq(expected_results)
    end
  end

  describe '#add_win' do
    let(:user) { Fabricate(:user, :longest_winning_streak => 1) }
    let(:other_user) { Fabricate(:user) }
    let(:match) do
      Fabricate(:match, :blue_score => 10, :red_score => 0, :finished_at => Time.now).tap do |m|
        Fabricate(:match_player, :match => m, :player => user, :team => 'blue')
        Fabricate(:match_player, :match => m, :player => other_user, :team => 'red')
      end
    end

    def add_win
      user.add_win(match)
    end

    it 'increments played' do
      expect { add_win }.should change { user.reload.played }.by(1)
    end

    it 'increments won' do
      expect { add_win }.should change { user.reload.won }.by(1)
    end

    it 'calculates the win/loss percentage' do
      user.expects(:calculate_win_loss_percentage)
      add_win
    end

    it 'updates last_won_at' do
      expect { add_win }.should change { user.reload.last_won_at.to_s }.to(match.finished_at.to_s)
    end

    it 'updates last_played_at' do
      expect { add_win }.should change { user.reload.last_played_at.to_s }.to(match.finished_at.to_s)
    end

    context 'current_streak > longest_winning_streak' do
      it 'updates longest_winning_streak' do
        user.stubs(:winning_streak).returns(42)
        expect { add_win }.should change { user.reload.longest_winning_streak }.to(42)
      end
    end

    context 'current_streak <= longest_winning_streak' do
      it 'does not update longest_winning_streak' do
        user.stubs(:winning_streak).returns(0)
        expect { add_win }.should_not change { user.reload.longest_winning_streak }

        user.stubs(:winning_streak).returns(user.longest_winning_streak)
        expect { add_win }.should_not change { user.reload.longest_winning_streak }
      end
    end

    context 'user stats' do
      context 'without teams' do
        it 'creates stat with other player as opponent with match data' do
          expect { add_win }.should change { user.reload.stats.count }.by(1)

          last_stat = user.stats.last
          last_stat.other_user.should eq(other_user)
          last_stat.relation.should eq('opponent')
          last_stat.won.should be_true
          last_stat.by.should eq(10)
        end
      end

      context 'with teams' do
        let(:blue_user) { Fabricate(:user) }
        let(:red_user) { Fabricate(:user) }

        before do
          Fabricate(:match_player, :match => match, :player => blue_user, :team => 'blue')
          Fabricate(:match_player, :match => match, :player => red_user, :team => 'red')
        end

        it 'creates stats for each additional player' do
          expect { add_win }.should change { user.reload.stats.count }.by(3)
        end

        it 'create stat with teammate as ally with match data' do
          add_win

          ally_stat = user.stats.first(:conditions => { :relation => 'ally' })
          ally_stat.other_user.should eq(blue_user)
          ally_stat.relation.should eq('ally')
          ally_stat.won.should be_true
          ally_stat.by.should eq(10)
        end

        it 'creates stats for other team as opponents with match data' do
          add_win
          opponent_stats = user.stats.all(:conditions => { :relation => 'opponent' })
          opponent_stats.count.should eq(2)

          expected_user_ids = [ other_user.id, red_user.id ]
          opponent_stats.collect(&:other_user_id).sort.should eq(expected_user_ids.sort)

          opponent_stats.each do |opponent_stat|
            opponent_stat.relation.should eq('opponent')
            opponent_stat.won.should be_true
            opponent_stat.by.should eq(10)
          end
        end
      end
    end
  end

  describe '#add_lost' do
    let(:user) { Fabricate(:user, :longest_losing_streak => 1) }
    let(:other_user) { Fabricate(:user) }
    let(:match) do
      Fabricate(:match, :red_score => 10, :blue_score => 0, :finished_at => Time.now).tap do |m|
        Fabricate(:match_player, :match => m, :player => user, :team => 'blue')
        Fabricate(:match_player, :match => m, :player => other_user, :team => 'red')
      end
    end

    def add_lost
      user.add_lost(match)
    end

    it 'increments played' do
      expect { add_lost }.should change { user.reload.played }.by(1)
    end

    it 'increments lost' do
      expect { add_lost }.should change { user.reload.lost }.by(1)
    end

    it 'calculates the win/loss percentage' do
      user.expects(:calculate_win_loss_percentage)
      add_lost
    end

    it 'updates last_lost_at' do
      expect { add_lost }.should change { user.reload.last_lost_at.to_s }.to(match.finished_at.to_s)
    end

    it 'updates last_played_at' do
      expect { add_lost }.should change { user.reload.last_played_at.to_s }.to(match.finished_at.to_s)
    end

    context 'current_streak > longest_losing_streak' do
      it 'updates longest_losing_streak' do
        user.stubs(:losing_streak).returns(42)
        expect { add_lost }.should change { user.reload.longest_losing_streak }.to(42)
      end
    end

    context 'current_streak <= longest_losing_streak' do
      it 'does not update longest_losing_streak' do
        user.stubs(:losing_streak).returns(0)
        expect { add_lost }.should_not change { user.reload.longest_losing_streak }

        user.stubs(:losing_streak).returns(user.longest_losing_streak)
        expect { add_lost }.should_not change { user.reload.longest_losing_streak }
      end
    end

    context 'user stats' do
      context 'without teams' do
        it 'creates stat with other player as opponent with match data' do
          expect { add_lost }.should change { user.reload.stats.count }.by(1)

          last_stat = user.stats.last
          last_stat.other_user.should eq(other_user)
          last_stat.relation.should eq('opponent')
          last_stat.won.should be_false
          last_stat.by.should eq(10)
        end
      end

      context 'with teams' do
        let(:blue_user) { Fabricate(:user) }
        let(:red_user) { Fabricate(:user) }

        before do
          Fabricate(:match_player, :match => match, :player => blue_user, :team => 'blue')
          Fabricate(:match_player, :match => match, :player => red_user, :team => 'red')
        end

        it 'creates stats for each additional player' do
          expect { add_lost }.should change { user.reload.stats.count }.by(3)
        end

        it 'create stat with teammate as ally with match data' do
          add_lost

          ally_stat = user.stats.first(:conditions => { :relation => 'ally' })
          ally_stat.other_user.should eq(blue_user)
          ally_stat.relation.should eq('ally')
          ally_stat.won.should be_false
          ally_stat.by.should eq(10)
        end

        it 'creates stats for other team as opponents with match data' do
          add_lost
          opponent_stats = user.stats.all(:conditions => { :relation => 'opponent' })
          opponent_stats.count.should eq(2)

          expected_user_ids = [ other_user.id, red_user.id ]
          opponent_stats.collect(&:other_user_id).sort.should eq(expected_user_ids.sort)

          opponent_stats.each do |opponent_stat|
            opponent_stat.relation.should eq('opponent')
            opponent_stat.won.should be_false
            opponent_stat.by.should eq(10)
          end
        end
      end
    end
  end

  describe '#winning_streak' do
    let(:user) { Fabricate.build(:user) }

    def winning_streak
      user.winning_streak
    end

    context 'last_played_at != last_won_at' do
      before do
        right_now           = Time.now
        user.last_played_at = nil
        user.last_won_at    = right_now
      end

      it 'returns 0' do
        winning_streak.should eq(0)
      end
    end

    context 'last_played_at == last_won_at' do
      before do
        right_now           = Time.now
        user.last_played_at = right_now
        user.last_won_at    = right_now
      end

      context 'last_lost_at is blank' do
        before { user.last_lost_at = nil }

        it 'returns the value of won' do
          user.won = 5
          winning_streak.should eq(5)

          user.won = 7
          winning_streak.should eq(7)
        end
      end

      context 'last_lost_at is not blank' do
        let(:last_lost_at) { Time.now }
        let(:mock_matches) { mock('mock_matches') }
        let(:match_args) do
          ['finished_at > ?', last_lost_at]
        end

        before { user.last_lost_at = last_lost_at }

        it 'returns the number of matches since last loss' do
          user.expects(:matches).returns(mock_matches)
          mock_matches.expects(:where).with(match_args).returns([ 1, 2 ])
          winning_streak.should eq(2)
        end
      end
    end
  end

  describe '#losing_streak' do
    let(:user) { Fabricate.build(:user) }

    def losing_streak
      user.losing_streak
    end

    context 'last_played_at != last_lost_at' do
      before do
        right_now           = Time.now
        user.last_played_at = nil
        user.last_lost_at   = right_now
      end

      it 'returns 0' do
        losing_streak.should eq(0)
      end
    end

    context 'last_played_at == last_lost_at' do
      before do
        right_now           = Time.now
        user.last_played_at = right_now
        user.last_lost_at   = right_now
      end

      context 'last_won_at is blank' do
        before { user.last_won_at = nil }

        it 'returns the value of lost' do
          user.lost = 5
          losing_streak.should eq(5)

          user.lost = 7
          losing_streak.should eq(7)
        end
      end

      context 'last_won_at is not blank' do
        let(:last_won_at) { Time.now }
        let(:mock_matches) { mock('mock_matches') }
        let(:match_args) do
          ['finished_at > ?', last_won_at]
        end

        before { user.last_won_at = last_won_at }

        it 'returns the number of matches since last win' do
          user.expects(:matches).returns(mock_matches)
          mock_matches.expects(:where).with(match_args).returns([ 1, 2 ])
          losing_streak.should eq(2)
        end
      end
    end
  end

  describe '#time_playing' do
    let(:user) { Fabricate.build(:user) }
    let(:mock_matches) { mock('mock_matches') }

    before { user.stubs(:matches).returns(mock_matches) }

    def time_playing
      user.time_playing
    end

    it 'only retrieves recorded matches' do
      mock_matches.expects(:where).with(:state => 'recorded').returns([])
      time_playing
    end

    it 'returns 0 when no matches are found' do
      mock_matches.stubs(:where).returns([])
      time_playing.should be_zero
    end

    it 'returns the sum of match duration_in_seconds values' do
      mock_match1 = mock('mock_match1', :duration_in_seconds => 3)
      mock_match2 = mock('mock_match1', :duration_in_seconds => 5)
      mock_matches.stubs(:where).returns([mock_match1, mock_match2])
      time_playing.should eq(8)
    end
  end

  describe '#calculate_win_loss_percentage' do
    it 'assigns the calculated value to user.win_loss_percentage' do
      user = Fabricate.build(:user, :win_loss_percentage => nil, :won => 7, :lost => 3)
      expect do
        user.calculate_win_loss_percentage
      end.should change { user.win_loss_percentage }.to(70.0)
    end
  end

  describe '#win_loss_percentage_i' do
    it 'returns the integer value of win_loss_percentage' do
      user = Fabricate.build(:user, :win_loss_percentage => 77.7)
      user.win_loss_percentage_i.should eq(77)
    end
  end

  describe '.wup_wup_playaz' do
    it 'returns top 5 users based on win_loss_percentage' do
      mock_result = mock('mock_result')
      User.expects(:order).with('win_loss_percentage DESC').returns(mock_result)
      mock_result.expects(:limit).with(5)
      User.wup_wup_playaz
    end
  end

  describe '#lost_per_day' do
    let!(:user) { Fabricate(:user) }

    context 'without results' do
      it 'returns an empty array' do
        user.lost_per_day.should eq([])
      end
    end

    context 'with results' do
      let(:losing_day1) { 9.days.ago }
      let(:losing_day2) { 7.days.ago }
      let!(:lost_match1) { Fabricate(:match, :started_at => losing_day1) }
      let!(:lost_match2) { Fabricate(:match, :started_at => losing_day1) }
      let!(:lost_match3) { Fabricate(:match, :started_at => losing_day2) }
      let!(:lost_match_player1) { Fabricate(:match_player, :player => user, :match => lost_match1) }
      let!(:lost_match_player2) { Fabricate(:match_player, :player => user, :match => lost_match2) }
      let!(:lost_match_player3) { Fabricate(:match_player, :player => user, :match => lost_match3) }
      let!(:lost_match_stat1) { Fabricate(:match_stat, :user => user, :match => lost_match1, :won => false) }
      let!(:lost_match_stat2) { Fabricate(:match_stat, :user => user, :match => lost_match2, :won => false) }
      let!(:lost_match_stat3) { Fabricate(:match_stat, :user => user, :match => lost_match3, :won => false) }
      let(:winning_day1) { 5.days.ago }
      let(:winning_day2) { 3.days.ago }
      let!(:won_match1) { Fabricate(:match, :started_at => winning_day1) }
      let!(:won_match2) { Fabricate(:match, :started_at => winning_day1) }
      let!(:won_match3) { Fabricate(:match, :started_at => winning_day2) }
      let!(:won_match_player1) { Fabricate(:match_player, :player => user, :match => won_match1) }
      let!(:won_match_player2) { Fabricate(:match_player, :player => user, :match => won_match2) }
      let!(:won_match_player3) { Fabricate(:match_player, :player => user, :match => won_match3) }
      let!(:won_match_stat1) { Fabricate(:match_stat, :user => user, :match => won_match1, :won => true) }
      let!(:won_match_stat2) { Fabricate(:match_stat, :user => user, :match => won_match2, :won => true) }
      let!(:won_match_stat3) { Fabricate(:match_stat, :user => user, :match => won_match3, :won => true) }
      let(:lost_per_day) { user.lost_per_day.collect{ |loss| [ loss[0].to_date.to_s, loss[1] ] } }

      it 'returns a two dimensional array' do
        lost_per_day.class.should eq(Array)
        lost_per_day.each do |result|
          result.class.should eq(Array)
        end
      end

      it 'returns lost match dates in first index of inner array' do
        first_index_values = lost_per_day.collect{ |loss| loss[0] }

        first_index_values.should include(losing_day1.to_date.to_s)
        first_index_values.should include(losing_day2.to_date.to_s)

        first_index_values.should_not include(winning_day1.to_date.to_s)
        first_index_values.should_not include(winning_day2.to_date.to_s)
      end

      it 'returns loss count per day in second index of inner array' do
        lost_per_day.should include([ losing_day1.to_date.to_s, 2 ])
        lost_per_day.should include([ losing_day2.to_date.to_s, 1 ])
      end
    end
  end

  describe '#won_per_day' do
    let!(:user) { Fabricate(:user) }

    context 'without results' do
      it 'returns an empty array' do
        user.won_per_day.should eq([])
      end
    end

    context 'with results' do
      let(:winning_day1) { 5.days.ago }
      let(:winning_day2) { 3.days.ago }
      let!(:won_match1) { Fabricate(:match, :started_at => winning_day1) }
      let!(:won_match2) { Fabricate(:match, :started_at => winning_day1) }
      let!(:won_match3) { Fabricate(:match, :started_at => winning_day2) }
      let!(:won_match_player1) { Fabricate(:match_player, :player => user, :match => won_match1) }
      let!(:won_match_player2) { Fabricate(:match_player, :player => user, :match => won_match2) }
      let!(:won_match_player3) { Fabricate(:match_player, :player => user, :match => won_match3) }
      let!(:won_match_stat1) { Fabricate(:match_stat, :user => user, :match => won_match1, :won => true) }
      let!(:won_match_stat2) { Fabricate(:match_stat, :user => user, :match => won_match2, :won => true) }
      let!(:won_match_stat3) { Fabricate(:match_stat, :user => user, :match => won_match3, :won => true) }
      let(:losing_day1) { 9.days.ago }
      let(:losing_day2) { 7.days.ago }
      let!(:lost_match1) { Fabricate(:match, :started_at => losing_day1) }
      let!(:lost_match2) { Fabricate(:match, :started_at => losing_day1) }
      let!(:lost_match3) { Fabricate(:match, :started_at => losing_day2) }
      let!(:lost_match_player1) { Fabricate(:match_player, :player => user, :match => lost_match1) }
      let!(:lost_match_player2) { Fabricate(:match_player, :player => user, :match => lost_match2) }
      let!(:lost_match_player3) { Fabricate(:match_player, :player => user, :match => lost_match3) }
      let!(:lost_match_stat1) { Fabricate(:match_stat, :user => user, :match => lost_match1, :won => false) }
      let!(:lost_match_stat2) { Fabricate(:match_stat, :user => user, :match => lost_match2, :won => false) }
      let!(:lost_match_stat3) { Fabricate(:match_stat, :user => user, :match => lost_match3, :won => false) }
      let(:won_per_day) { user.won_per_day.collect{ |win| [ win[0].to_date.to_s, win[1] ] } }

      it 'returns a two dimensional array' do
        won_per_day.class.should eq(Array)
        won_per_day.each do |result|
          result.class.should eq(Array)
        end
      end

      it 'returns won match dates in first index of inner array' do
        first_index_values = won_per_day.collect{ |win| win[0] }

        first_index_values.should include(winning_day1.to_date.to_s)
        first_index_values.should include(winning_day2.to_date.to_s)

        first_index_values.should_not include(losing_day1.to_date.to_s)
        first_index_values.should_not include(losing_day2.to_date.to_s)
      end

      it 'returns win count per day in second index of inner array' do
        won_per_day.should include([ winning_day1.to_date.to_s, 2 ])
        won_per_day.should include([ winning_day2.to_date.to_s, 1 ])
      end
    end
  end

  describe '#number_matches_against' do
    let(:user) { Fabricate.build(:user) }
    let(:other_user) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_opponents) { mock('mock_opponents') }

    it 'raises an error without any arguments' do
      expect { user.number_matches_against }.should raise_error(ArgumentError)
    end

    it 'does not raise an error with one argument' do
      expect { user.number_matches_against(other_user) }.should_not raise_error(ArgumentError)
    end

    it 'returns count of stats where received user is an opponent' do
      user.expects(:stats).returns(mock_stats)
      mock_stats.expects(:opponents).returns(mock_opponents)
      mock_opponents.expects(:where).with(:other_user_id => other_user).returns([ 1 ])
      user.number_matches_against(other_user).should eq(1)
    end
  end

  describe '#number_matches_with' do
    let(:user) { Fabricate.build(:user) }
    let(:other_user) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_allies) { mock('mock_allies') }

    it 'raises an error without any arguments' do
      expect { user.number_matches_with }.should raise_error(ArgumentError)
    end

    it 'does not raise an error with one argument' do
      expect { user.number_matches_with(other_user) }.should_not raise_error(ArgumentError)
    end

    it 'returns count of stats where received user is an ally' do
      user.expects(:stats).returns(mock_stats)
      mock_stats.expects(:allies).returns(mock_allies)
      mock_allies.expects(:where).with(:other_user_id => other_user).returns([ 1 ])
      user.number_matches_with(other_user).should eq(1)
    end
  end

  describe '#nemesis' do
    let(:user) { Fabricate.build(:user) }
    let(:opponent) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_opponents) { mock('mock_opponents') }
    let(:mock_lost) { mock('mock_lost') }
    let(:mock_group) { mock('mock_group') }
    let(:mock_order) { mock('mock_order') }
    let(:mock_limit) { mock('mock_limit') }
    let(:mock_count) { mock('mock_count') }

    context 'without argument' do
      it 'does not raise an error' do
        expect { user.nemesis }.should_not raise_error(ArgumentError)
      end

      it 'returns opponent lost to the most in an array' do
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:opponents).returns(mock_opponents)
        mock_opponents.expects(:lost).returns(mock_lost)
        mock_lost.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(1).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([opponent])
        user.nemesis.should eq([opponent])
      end
    end

    context 'with an argument' do
      it 'does not raise an error' do
        expect { user.nemesis(1) }.should_not raise_error(ArgumentError)
      end

      it 'returns opponent lost to the most in an array' do
        limit = 5
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:opponents).returns(mock_opponents)
        mock_opponents.expects(:lost).returns(mock_lost)
        mock_lost.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(limit).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([opponent])
        user.nemesis(limit).should eq([opponent])
      end
    end
  end

  describe '#walkovers' do
    let(:user) { Fabricate.build(:user) }
    let(:opponent) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_opponents) { mock('mock_opponents') }
    let(:mock_won) { mock('mock_won') }
    let(:mock_group) { mock('mock_group') }
    let(:mock_order) { mock('mock_order') }
    let(:mock_limit) { mock('mock_limit') }
    let(:mock_count) { mock('mock_count') }

    context 'without argument' do
      it 'does not raise an error' do
        expect { user.walkovers }.should_not raise_error(ArgumentError)
      end

      it 'returns opponent defeated the most in an array' do
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:opponents).returns(mock_opponents)
        mock_opponents.expects(:won).returns(mock_won)
        mock_won.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(1).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([opponent])
        user.walkovers.should eq([opponent])
      end
    end

    context 'with an argument' do
      it 'does not raise an error' do
        expect { user.walkovers(1) }.should_not raise_error(ArgumentError)
      end

      it 'returns opponent defeated the most in an array' do
        limit = 5
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:opponents).returns(mock_opponents)
        mock_opponents.expects(:won).returns(mock_won)
        mock_won.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(limit).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([opponent])
        user.walkovers(limit).should eq([opponent])
      end
    end
  end

  describe '#dream_team' do
    let(:user) { Fabricate.build(:user) }
    let(:teammate) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_allies) { mock('mock_allies') }
    let(:mock_won) { mock('mock_won') }
    let(:mock_group) { mock('mock_group') }
    let(:mock_order) { mock('mock_order') }
    let(:mock_limit) { mock('mock_limit') }
    let(:mock_count) { mock('mock_count') }

    context 'without argument' do
      it 'does not raise an error' do
        expect { user.dream_team }.should_not raise_error(ArgumentError)
      end

      it 'returns teammate with the most wins in an array' do
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:allies).returns(mock_allies)
        mock_allies.expects(:won).returns(mock_won)
        mock_won.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(1).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([teammate])
        user.dream_team.should eq([teammate])
      end
    end

    context 'with an argument' do
      it 'does not raise an error' do
        expect { user.dream_team(1) }.should_not raise_error(ArgumentError)
      end

      it 'returns teammate with the most wins in an array' do
        limit = 5
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:allies).returns(mock_allies)
        mock_allies.expects(:won).returns(mock_won)
        mock_won.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(limit).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([teammate])
        user.dream_team(limit).should eq([teammate])
      end
    end
  end

  describe '#useless_team' do
    let(:user) { Fabricate.build(:user) }
    let(:teammate) { Fabricate.build(:user) }
    let(:mock_stats) { mock('mock_stats') }
    let(:mock_allies) { mock('mock_allies') }
    let(:mock_lost) { mock('mock_lost') }
    let(:mock_group) { mock('mock_group') }
    let(:mock_order) { mock('mock_order') }
    let(:mock_limit) { mock('mock_limit') }
    let(:mock_count) { mock('mock_count') }

    context 'without argument' do
      it 'does not raise an error' do
        expect { user.useless_team }.should_not raise_error(ArgumentError)
      end

      it 'returns teammate with the most losses in an array' do
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:allies).returns(mock_allies)
        mock_allies.expects(:lost).returns(mock_lost)
        mock_lost.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(1).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([teammate])
        user.useless_team.should eq([teammate])
      end
    end

    context 'with an argument' do
      it 'does not raise an error' do
        expect { user.useless_team(1) }.should_not raise_error(ArgumentError)
      end

      it 'returns teammate with the most losses in an array' do
        limit = 5
        user.expects(:stats).returns(mock_stats)
        mock_stats.expects(:allies).returns(mock_allies)
        mock_allies.expects(:lost).returns(mock_lost)
        mock_lost.expects(:group).with(:other_user).returns(mock_group)
        mock_group.expects(:order).with('count_all DESC').returns(mock_order)
        mock_order.expects(:limit).with(limit).returns(mock_limit)
        mock_limit.expects(:count).returns(mock_count)
        mock_count.expects(:to_a).returns([teammate])
        user.useless_team(limit).should eq([teammate])
      end
    end
  end
end
