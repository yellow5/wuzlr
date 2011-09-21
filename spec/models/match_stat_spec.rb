require 'spec_helper'

describe MatchStat do
  describe 'attributes' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:match_id).of_type(:integer) }
    it { should have_db_column(:won).of_type(:boolean) }
    it { should have_db_column(:by).of_type(:integer) }
  end

  describe 'associations' do
    it { should belong_to(:match) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let!(:won_match_stat) { Fabricate(:match_stat, :won => true) }
    let!(:lost_match_stat) { Fabricate(:match_stat, :won => false) }

    context 'won' do
      subject { MatchStat.won }

      it 'returns records with :won => true' do
        subject.should eq([won_match_stat])
      end
    end

    context 'lost' do
      subject { MatchStat.lost }

      it 'returns records with :won => false' do
        subject.should eq([lost_match_stat])
      end
    end
  end
end
