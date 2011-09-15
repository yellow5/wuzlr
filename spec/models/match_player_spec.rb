require 'spec_helper'

describe MatchPlayer do
  describe 'attributes' do
    it { should have_db_column(:team).of_type(:string) }
    it { should have_db_column(:position).of_type(:integer) }
    it { should have_db_column(:match_id).of_type(:integer) }
    it { should have_db_column(:player_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { should belong_to(:player) }
    it { should belong_to(:match) }
  end
end
