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
end
