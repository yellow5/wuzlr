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
end
