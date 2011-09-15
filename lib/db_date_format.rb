module DbDateFormat
  def db_date_format(args={ :field => 'started_at', :format => 'YYYY Mon DD' })
    "to_char(#{args[:field]}, '#{args[:format]}')"
  end
end
