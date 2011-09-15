require 'spec_helper'

describe MatchStat do
  describe 'attributes' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:match_id).of_type(:integer) }
    it { should have_db_column(:won).of_type(:boolean) }
    it { should have_db_column(:by).of_type(:integer) }
  end
end
