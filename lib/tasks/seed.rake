namespace :db do
  desc <<-EOS
    Loads seed data for the current environment. It will look for
    ruby seed files in <Rails.root>/db/fixtures/ and 
    <Rails.root>/db/fixtures/<Rails.env>/.

    By default it will load any ruby files found. You can filter the files
    loaded by passing in the SEED environment variable with a comma-delimited
    list of patterns to include. Any files not matching the pattern will
    not be loaded.
    
    You can also change the directory where seed files are looked for
    with the FIXTURE_PATH environment variable. 
    
    Examples:
      # default, to load all seed files for the current environment
      rake db:seed
      
      # to load seed files matching orders or customers
      rake db:seed SEED=orders,customers
      
      # to load files from Rails.root/features/fixtures
      rake db:seed FIXTURE_PATH=features/fixtures 
  EOS
  task :seed => :environment do
    fixture_path = ENV["FIXTURE_PATH"] ? ENV["FIXTURE_PATH"] : "db/fixtures"

    global_seed_files = Dir[File.join(Rails.root, fixture_path, '*.rb')].sort
    env_specific_seed_files = Dir[File.join(Rails.root, fixture_path, Rails.env, '*.rb')]
    potential_seed_files = (global_seed_files + env_specific_seed_files).uniq
    
    if ENV["SEED"]
      filter = ENV["SEED"].gsub(/,/, "|")
      potential_seed_files.reject!{ |file| true unless file =~ /#{filter}/ }
      puts "\n == Filtering seed files against regexp: #{filter}"
    end

    potential_seed_files.each do |file|
      pretty_name = file.sub("#{Rails.root}/", "")
      puts "\n== Seed from #{pretty_name} " + ("=" * (60 - (17 + File.split(file).last.length)))
      load file
    end
  end
end
