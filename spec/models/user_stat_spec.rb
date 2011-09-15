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
end
