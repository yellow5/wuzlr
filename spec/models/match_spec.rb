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
end
