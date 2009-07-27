desc 'Create YAML test fixtures from data in an existing database.  
Defaults to development database.  Set RAILS_ENV to override.'
 
#require 'Ya2YAML'
require File.join(File.dirname(__FILE__),"../../vendor/ya2yaml.rb")
 
task :extract_fixtures => :environment do
  extend RailsReflection

  def self.name_fixture_row(table_name, model, i, rec)
    case model.to_s
    when Artist.to_s, Album.to_s, Track.to_s
      rec['name'].gsub(/\s|:/,'_').underscore
    else
      "#{table_name}_#{i.succ!}"
    end
  end

  sql= "SELECT * FROM %s"
  ActiveRecord::Base.establish_connection
  conn= ActiveRecord::Base.connection

  table_map= all_models.inject({}){|map,model| map[model.table_name]= model; map}
  table_map.delete "bdrb_job_queues"
  tables= table_map.keys.sort

  tables.each_with_index do |table_name, table_index|
    puts "[#{table_index+1}/#{tables.size}] #{table_name}"
    model= table_map[table_name]
    i= "000"
    fixture= {}
    data= conn.select_all(sql % table_name)
    data.each{|orig_rec|
      new_rec= {}
      orig_rec.each{|k,v|
        unless %[created_at updated_at].include?(k) or v.nil?
          new_rec[k]= v.safe_to_i.safe_to_f
        end
      }
      row_name= name_fixture_row(table_name,model,i,new_rec)
      fixture[row_name]= new_rec
    }
    File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
      file.write fixture.ya2yaml
    end
  end
end
