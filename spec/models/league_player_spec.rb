require 'spec_helper'

describe LeaguePlayer do
  describe 'attributes' do
    it { should have_db_column(:league_id).of_type(:integer) }
    it { should have_db_column(:player_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end
end
