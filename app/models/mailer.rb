class Mailer < ActionMailer::Base
  default :from => 'noreply@chuzlr.com'

  def invitation(to, league)
    @league = league
    mail(:to => to, :subject => "You have been summoned to chuzlr!")
  end
end
