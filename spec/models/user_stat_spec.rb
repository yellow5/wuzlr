require 'spec_helper'

describe UserStat do
  describe 'attributes' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:other_user_id).of_type(:integer) }
    it { should have_db_column(:relation).of_type(:string) }
    it { should have_db_column(:match_id).of_type(:integer) }
    it { should have_db_column(:won).of_type(:boolean) }
    it { should have_db_column(:by).of_type(:integer) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:other_user) }
  end

  describe 'scopes' do
    context 'opponents and allies scopes' do
      let!(:opponent_user_stat) { Fabricate(:user_stat, :relation => 'opponent') }
      let!(:ally_user_stat) { Fabricate(:user_stat, :relation => 'ally') }

      context 'opponents' do
        subject { UserStat.opponents }

        it "returns records with :relation => 'opponent'" do
          subject.should eq([opponent_user_stat])
        end
      end

      context 'allies' do
        subject { UserStat.allies }

        it "returns records with :relation => 'ally'" do
          subject.should eq([ally_user_stat])
        end
      end
    end

    context 'won and lost scopes' do
      let!(:won_user_stat) { Fabricate(:user_stat, :won => true) }
      let!(:lost_user_stat) { Fabricate(:user_stat, :won => false) }

      context 'won' do
        subject { UserStat.won }

        it 'returns records with :won => true' do
          subject.should eq([won_user_stat])
        end
      end

      context 'lost' do
        subject { UserStat.lost }

        it 'returns records with :won => false' do
          subject.should eq([lost_user_stat])
        end
      end
    end
  end
end
