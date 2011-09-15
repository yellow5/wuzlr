require 'spec_helper'

describe FifaTeam do
  describe 'attributes' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:flag).of_type(:string) }
    it { should have_db_column(:goals_for).of_type(:integer) }
    it { should have_db_column(:goals_against).of_type(:integer) }
    it { should have_db_column(:penalty_goal).of_type(:integer) }
    it { should have_db_column(:goals_for_average).of_type(:integer) }
    it { should have_db_column(:yellow_cards).of_type(:integer) }
    it { should have_db_column(:second_yellow_cards).of_type(:integer) }
    it { should have_db_column(:red_cards).of_type(:integer) }
    it { should have_db_column(:matches_played).of_type(:integer) }
    it { should have_db_column(:won).of_type(:integer) }
    it { should have_db_column(:draw).of_type(:integer) }
    it { should have_db_column(:lost).of_type(:integer) }
  end
end
