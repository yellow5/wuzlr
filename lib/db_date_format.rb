module DbDateFormat
  def db_date_format(args={ :field => 'started_at', :format => 'YYYY Mon DD' })
    if Rails.env == 'production'
      "to_char(#{args[:field]}, '#{args[:format]}')"
    else
      "strftime('#{args[:format]}', #{args[:field]})"
    end
  end
end
