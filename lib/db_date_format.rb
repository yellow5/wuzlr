module DbDateFormat
  def db_date_format(args={ :field => 'started_at', :format => '%Y %b %d' })
    if Rails.env == 'production'
      "DATE_FORMAT(#{args[:field]}, '#{args[:format]}')"
    else
      "strftime('#{args[:format]}', #{args[:field]})"
    end
  end
end
