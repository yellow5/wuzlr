class Mailer < ActionMailer::Base
  default :from => DO_NOT_REPLY

  def invitation(to, league)
    @league = league
    mail(:to => recipients, :subject => "You have been summoned to Wuzlr!")
  end
end
