require 'spec_helper'

describe User do
  describe 'mixins' do
    subject { User.included_modules }

    it { should include(DbDateFormat) }
    it { should include(Devise::Models::Authenticatable) }
    it { should include(Devise::Models::Recoverable) }
    it { should include(Devise::Models::Registerable) }
    it { should include(Devise::Models::Rememberable) }
    it { should include(Devise::Models::Trackable) }
    it { should include(Devise::Models::Validatable) }
  end

  describe 'attributes' do
    it { should have_db_column(:email).of_type(:string).with_options(:default => '', :null => false) }
    it { should have_db_column(:encrypted_password).of_type(:string).with_options(:limit => 128, :default => '', :null => false) }
    it { should have_db_column(:reset_password_token).of_type(:string) }
    it { should have_db_column(:remember_token).of_type(:string) }
    it { should have_db_column(:remember_created_at).of_type(:datetime) }
    it { should have_db_column(:sign_in_count).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:current_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:last_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:current_sign_in_ip).of_type(:string) }
    it { should have_db_column(:last_sign_in_ip).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:played).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:won).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:lost).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:last_played_at).of_type(:datetime) }
    it { should have_db_column(:last_won_at).of_type(:datetime) }
    it { should have_db_column(:last_lost_at).of_type(:datetime) }
    it { should have_db_column(:longest_winning_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:longest_losing_streak).of_type(:integer).with_options(:default => 0) }
    it { should have_db_column(:win_loss_percentage).of_type(:float).with_options(:default => 0.0) }
  end

  describe 'indexes' do
    it { should have_db_index(:email).unique(true) }
    it { should have_db_index(:reset_password_token).unique(true) }
  end

  describe 'associations' do
    it { should have_many(:league_players) }
    it { should have_many(:leagues).through(:league_players) }
    it { should have_many(:match_players) }
    it { should have_many(:matches).through(:match_players) }
    it { should have_many(:stats) }
    it { should have_many(:match_stats) }
    it { should have_many(:league_stats) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'accessible attributes' do
    subject { User.accessible_attributes }

    it { should include(:name) }
    it { should include(:email) }
    it { should include(:password) }
    it { should include(:password_confirmation) }
    it { should include(:remember_me) }
  end

  context 'before save' do
    context 'email is mhaskins@changehealthcare.com' do
      let(:user) { Fabricate.build(:user, :email => 'mhaskins@changehealthcare.com') }
      let(:sprinkles) { 'Michael "Sprinkles" Haskins' }

      it 'changes name to Michael "Sprinkles" Haskins' do
        expect { user.save! }.should change { user.name }.to(sprinkles)

        user.name = 'Michael Haskins'
        expect { user.save! }.should change { user.name }.to(sprinkles)

        user.name = 'Trololo'
        expect { user.save! }.should change { user.name }.to(sprinkles)
      end
    end
  end

  describe '#win_p' do
    let(:user) { User.new }

    context 'played is > 0' do
      before { user.played = 10 }

      it 'returns the percentage of games won' do
        [1, 4, 7].each do |won|
          user.won = won
          user.win_p.should eq(won * 10)
        end
      end
    end

    context 'played is not > 0' do
      it 'returns 0' do
        user.won = 1
        [0, -1].each do |played|
          user.played = played
          user.win_p.should eq(0)
        end
      end
    end
  end
end
