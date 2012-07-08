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
      let(:red_user) { Fabricate(:user) }
      let(:blue_user) { Fabricate(:user) }
      let!(:match) do
        Fabricate(:match).tap do |new_match|
          Fabricate(:match_player, :match => new_match, :team => 'red', :player => red_user)
          Fabricate(:match_player, :match => new_match, :team => 'blue', :player => blue_user)
        end
      end

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

  describe '#state state machine' do
    context 'state' do
      [:planning, :playing, :finished, :recorded].each do |state|
        it "can be #{state}" do
          subject.respond_to?("#{state}?").should be_true
        end
      end

      it 'defaults to planning' do
        subject.state.should eq('planning')
      end
    end

    context 'planning state' do
      let(:match) { Fabricate.build(:match, :state => 'planning', :started_at => nil) }

      subject { match }

      context 'kick_off event' do
        it 'is available' do
          subject.state_events.should include(:kick_off)
        end

        it 'can transition to playing' do
          subject.kick_off_transition.to.should eq('playing')
        end

        context 'started_at is blank' do
          let!(:right_now) { Time.now }

          before { Time.stubs(:now).returns(right_now) }

          it 'sets started_at to Time.now' do
            expect do
              match.kick_off
            end.to change { match.started_at }.to(right_now)
          end
        end
      end
    end

    context 'playing state' do
      let(:match) { Fabricate.build(:match, :state => 'playing', :started_at => Time.now) }

      subject { match }

      context 'validations' do
        let(:player1) { Fabricate.build(:user) }
        let(:player2) { Fabricate.build(:user) }

        it { should validate_presence_of(:started_at) }

        it 'validates that both sides have players' do
          match.stubs(:blue_players).returns([])
          match.stubs(:red_players).returns([player1])
          subject.valid?.should be_false
          subject.errors.full_messages.should include('Need at least one blue player')

          match.stubs(:red_players).returns([])
          match.stubs(:blue_players).returns([player1])
          subject.valid?.should be_false
          subject.errors.full_messages.should include('Need at least one red player')

          match.stubs(:red_players).returns([player1])
          match.stubs(:blue_players).returns([player2])
          subject.valid?.should be_true
        end

        it 'validates that players are unique' do
          match.stubs(:red_players).returns([player1])
          match.stubs(:blue_players).returns([player2])

          match.stubs(:players).returns([player1, player1, player2])
          subject.valid?.should be_false
          subject.errors.full_messages.should include("#{player1.name} can only play in one position")
          subject.errors.full_messages.should_not include("#{player2.name} can only play in one position")

          match.stubs(:players).returns([player1, player2])
          subject.valid?.should be_true
        end
      end

      context 'full_time event' do
        it 'is available' do
          subject.state_events.should include(:full_time)
        end

        it 'can transition to finished' do
          subject.full_time_transition.to.should eq('finished')
        end
      end
    end

    context 'finished state' do
      let(:match) { Fabricate.build(:match, :state => 'finished', :blue_score => 10, :red_score => 9) }

      subject { match }

      context 'validations' do
        it { should validate_presence_of(:finished_at) }
      end

      context 'record event' do
        it 'is available' do
          subject.state_events.should include(:record)
        end

        it 'can transition to recorded' do
          subject.record_transition.to.should eq('recorded')
        end

        context 'match winners' do
          let!(:player) { Fabricate(:user) }

          before { match.stubs(:winners).returns([player]) }

          it 'adds win for players' do
            player.expects(:add_win)
            match.record
          end

          it 'creates match stat for players' do
            expect { match.record }.to change { match.stats.count }.by(1)
            last_stat = match.stats.last
            last_stat.user.should eq(player)
            last_stat.won.should be_true
            last_stat.by.should eq(match.score_difference)
          end

          it 'adds win to league' do
            match.league.expects(:add_win)
            match.record
          end
        end

        context 'match losers' do
          let!(:player) { Fabricate(:user) }

          before { match.stubs(:losers).returns([player]) }

          it 'adds loss for players' do
            player.expects(:add_lost)
            match.record
          end

          it 'creates match stat for players' do
            expect { match.record }.to change { match.stats.count }.by(1)
            last_stat = match.stats.last
            last_stat.user.should eq(player)
            last_stat.won.should be_false
            last_stat.by.should eq(match.score_difference)
          end

          it 'adds loss to league' do
            match.league.expects(:add_lost)
            match.record
          end
        end
      end
    end

    context 'recorded state' do
      let(:match) { Fabricate.build(:match, :state => 'recorded') }

      subject { match }

      context 'validations' do
        it { should ensure_inclusion_of(:red_score).in_range(0..10) }
        it { should ensure_inclusion_of(:blue_score).in_range(0..10) }

        it 'validates that red_score or blue_score is 10' do
          match.red_score = match.blue_score = 0
          subject.valid?.should be_false
          subject.errors.full_messages.should include('One team only must score 10')

          match.red_score  = 10
          match.blue_score = 0
          subject.valid?.should be_true

          match.blue_score = 10
          match.red_score  = 0
          subject.valid?.should be_true
        end
      end
    end
  end

  describe '#winner' do
    context 'red_score > blue_score' do
      let(:match) { ::Match.new(:red_score => 10, :blue_score => 0) }

      it 'returns red' do
        match.winner.should eq('red')
      end
    end

    context 'blue_score > red_score' do
      let(:match) { ::Match.new(:blue_score => 10, :red_score => 0) }

      it 'returns blue' do
        match.winner.should eq('blue')
      end
    end

    context 'blue_score == red_score' do
      let(:match) { ::Match.new(:blue_score => 0, :red_score => 0) }

      it 'returns nil' do
        match.winner.should be_nil
      end
    end
  end

  describe '#loser' do
    let(:match) { ::Match.new }

    context 'winner is red' do
      before { match.stubs(:winner).returns('red') }

      it 'returns blue' do
        match.loser.should eq('blue')
      end
    end

    context 'winner is blue' do
      before { match.stubs(:winner).returns('blue') }

      it 'returns red' do
        match.loser.should eq('red')
      end
    end

    context 'winner is nil' do
      before { match.stubs(:winner).returns(nil) }

      it 'returns nil' do
        match.loser.should be_nil
      end
    end
  end

  describe '#loser_score' do
    let(:match) { ::Match.new(:red_score => 5, :blue_score => 7) }

    it 'returns score for loser' do
      match.stubs(:loser).returns('red')
      match.loser_score.should eq(5)

      match.stubs(:loser).returns('blue')
      match.loser_score.should eq(7)
    end
  end

  describe '#score_difference' do
    let(:red_match) { ::Match.new(:red_score => 10, :blue_score => 7) }
    let(:blue_match) { ::Match.new(:blue_score => 10, :red_score => 7) }

    it 'returns absolute value of difference between scores' do
      red_match.score_difference.should eq(3)
      blue_match.score_difference.should eq(3)
    end
  end

  describe '#winners' do
    let(:match) { Fabricate(:match) }
    let(:red_player) { Fabricate(:match_player, :match => match, :team => 'red') }
    let(:blue_player) { Fabricate(:match_player, :match => match, :team => 'blue') }

    context 'winner is red' do
      before { match.stubs(:winner).returns('red') }

      it 'returns red players' do
        match.winners.should eq([red_player.player])
      end
    end

    context 'winner is blue' do
      before { match.stubs(:winner).returns('blue') }

      it 'returns blue players' do
        match.winners.should eq([blue_player.player])
      end
    end

    context 'winner is nil' do
      before { match.stubs(:winner).returns(nil) }

      it 'returns nil' do
        match.winners.should be_nil
      end
    end
  end

  describe '#losers' do
    let(:match) { Fabricate(:match) }
    let(:red_player) { Fabricate(:match_player, :match => match, :team => 'red') }
    let(:blue_player) { Fabricate(:match_player, :match => match, :team => 'blue') }

    context 'loser is red' do
      before { match.stubs(:loser).returns('red') }

      it 'returns red players' do
        match.losers.should eq([red_player.player])
      end
    end

    context 'loser is blue' do
      before { match.stubs(:loser).returns('blue') }

      it 'returns blue players' do
        match.losers.should eq([blue_player.player])
      end
    end

    context 'loser is nil' do
      before { match.stubs(:loser).returns(nil) }

      it 'returns nil' do
        match.losers.should be_nil
      end
    end
  end

  describe '#duration' do
    let(:started_at) { 1.hour.ago }
    let(:finished_at) { started_at + 10.minutes }
    let(:expected_duration) { Time.at(finished_at - started_at) }
    let(:match) { ::Match.new(:started_at => started_at, :finished_at => finished_at) }

    subject { match.duration }

    it 'returns time difference of finished_at and started_at as Time' do
      subject.should eq(expected_duration)
    end
  end

  describe '#duration_in_seconds' do
    let(:started_at) { 1.hour.ago }
    let(:finished_at) { started_at + 10.minutes }
    let(:expected_seconds) { finished_at - started_at }
    let(:match) { ::Match.new(:started_at => started_at, :finished_at => finished_at) }

    subject { match.duration_in_seconds }

    it 'returns time difference of finished_at and started_at in seconds' do
      subject.should eq(expected_seconds)
    end
  end

  describe '#team_with' do
    let(:user) { User.new }
    let(:match) { ::Match.new }

    subject { match.team_with(user) }

    it 'raises an error without an argument' do
      expect { match.team_with }.to raise_error(ArgumentError)
    end

    context 'red players include user' do
      before { match.stubs(:red_players).returns([user]) }

      it 'returns red' do
        subject.should eq('red')
      end
    end

    context 'blue players include user' do
      before { match.stubs(:blue_players).returns([user]) }

      it 'returns blue' do
        subject.should eq('blue')
      end
    end

    context 'no players include user' do
      it 'returns nil' do
        subject.should be_nil
      end
    end
  end

  describe '#team_without' do
    let(:user) { User.new }
    let(:match) { ::Match.new }

    subject { match.team_without(user) }

    it 'raises an error without an argument' do
      expect { match.team_without }.to raise_error(ArgumentError)
    end

    context 'red players include user' do
      before { match.stubs(:red_players).returns([user]) }

      it 'returns blue' do
        subject.should eq('blue')
      end
    end

    context 'blue players include user' do
      before { match.stubs(:blue_players).returns([user]) }

      it 'returns red' do
        subject.should eq('red')
      end
    end

    context 'no players include user' do
      it 'returns nil' do
        subject.should be_nil
      end
    end
  end

  describe '#players_for' do
    let(:red_player) { User.new }
    let(:blue_player) { User.new }
    let(:red_players) { [ red_player ] }
    let(:blue_players) { [ blue_player ] }
    let(:match) { ::Match.new }

    before do
      match.stubs(:red_players).returns(red_players)
      match.stubs(:blue_players).returns(blue_players)
    end

    def do_invoke(team)
      match.players_for(team)
    end

    it 'raises an error without an argument' do
      expect { match.players_for }.to raise_error(ArgumentError)
    end

    context 'team is red' do
      it 'returns red players' do
        do_invoke('red').should eq(red_players)
      end
    end

    context 'team is blue' do
      it 'returns blue players' do
        do_invoke('blue').should eq(blue_players)
      end
    end

    context 'team is nil' do
      it 'returns nil' do
        do_invoke(nil).should be_nil
      end
    end
  end

  describe '#score_for' do
    let(:expected_red_score) { 7 }
    let(:expected_blue_score) { 9 }
    let(:match) { ::Match.new(:red_score => expected_red_score, :blue_score => expected_blue_score) }

    def do_invoke(team)
      match.score_for(team)
    end

    it 'raises an error without an argument' do
      expect { match.score_for }.to raise_error(ArgumentError)
    end

    context 'team is red' do
      it 'returns red score' do
        do_invoke('red').should eq(expected_red_score)
      end
    end

    context 'team is blue' do
      it 'returns blue score' do
        do_invoke('blue').should eq(expected_blue_score)
      end
    end

    context 'team is nil' do
      it 'returns nil' do
        do_invoke(nil).should be_nil
      end
    end
  end
end
