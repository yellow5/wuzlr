require 'spec_helper'

describe League do
  describe 'mixins' do
    subject { League.included_modules }

    it { should include(DbDateFormat) }
  end

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

  describe 'validations' do
    context 'new record' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:user) }
    end

    context 'existing record' do
      let(:user) { User.create!(:email => 'user1@email.com', :password => 'asdf1234', :name => 'User 1') }
      let!(:league) { League.create!(:name => 'League Name', :user_id => user.id) }

      subject { league }

      it { should_not validate_presence_of(:user) }
    end
  end
end
