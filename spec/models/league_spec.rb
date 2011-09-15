require 'spec_helper'

describe League do
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
end
