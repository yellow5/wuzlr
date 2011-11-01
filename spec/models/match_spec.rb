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

  describe '#winner' do
    context 'red_score > blue_score' do
      let(:match) { Match.new(:red_score => 10, :blue_score => 0) }

      it 'returns red' do
        match.winner.should eq('red')
      end
    end

    context 'blue_score > red_score' do
      let(:match) { Match.new(:blue_score => 10, :red_score => 0) }

      it 'returns blue' do
        match.winner.should eq('blue')
      end
    end

    context 'blue_score == red_score' do
      let(:match) { Match.new(:blue_score => 0, :red_score => 0) }

      it 'returns nil' do
        match.winner.should be_nil
      end
    end
  end

  describe '#loser' do
    let(:match) { Match.new }

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
    let(:match) { Match.new(:red_score => 5, :blue_score => 7) }

    it 'returns score for loser' do
      match.stubs(:loser).returns('red')
      match.loser_score.should eq(5)

      match.stubs(:loser).returns('blue')
      match.loser_score.should eq(7)
    end
  end

  describe '#score_difference' do
    let(:red_match) { Match.new(:red_score => 10, :blue_score => 7) }
    let(:blue_match) { Match.new(:blue_score => 10, :red_score => 7) }

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
    let(:match) { Match.new(:started_at => started_at, :finished_at => finished_at) }

    subject { match.duration }

    it 'returns time difference of finished_at and started_at as Time' do
      subject.should eq(expected_duration)
    end
  end

  describe '#duration_in_seconds' do
    let(:started_at) { 1.hour.ago }
    let(:finished_at) { started_at + 10.minutes }
    let(:expected_seconds) { finished_at - started_at }
    let(:match) { Match.new(:started_at => started_at, :finished_at => finished_at) }

    subject { match.duration_in_seconds }

    it 'returns time difference of finished_at and started_at in seconds' do
      subject.should eq(expected_seconds)
    end
  end

  describe '#team_with' do
    let(:user) { User.new }
    let(:match) { Match.new }

    subject { match.team_with(user) }

    it 'raises an error without an argument' do
      expect { match.team_with }.should raise_error(ArgumentError)
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
    let(:match) { Match.new }

    subject { match.team_without(user) }

    it 'raises an error without an argument' do
      expect { match.team_without }.should raise_error(ArgumentError)
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
    let(:match) { Match.new }

    before do
      match.stubs(:red_players).returns(red_players)
      match.stubs(:blue_players).returns(blue_players)
    end

    def do_invoke(team)
      match.players_for(team)
    end

    it 'raises an error without an argument' do
      expect { match.players_for }.should raise_error(ArgumentError)
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
    let(:match) { Match.new(:red_score => expected_red_score, :blue_score => expected_blue_score) }

    def do_invoke(team)
      match.score_for(team)
    end

    it 'raises an error without an argument' do
      expect { match.score_for }.should raise_error(ArgumentError)
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
