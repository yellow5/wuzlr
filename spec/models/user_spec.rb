require 'spec_helper'

describe User do
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
end
