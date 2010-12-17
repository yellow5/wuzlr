class Mailer < ActionMailer::Base
  default :from => 'noreply@chuzlr.com'

  def invitation(to, league)
    @league = league
    mail(:to => recipients, :subject => "You have been summoned to Wuzlr!")
  end
end
