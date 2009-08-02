desc 'Create YAML test fixtures from data in an existing database.  
Defaults to development database.  Set RAILS_ENV to override.'

#require 'Ya2YAML'
require File.join(File.dirname(__FILE__),"../../vendor/ya2yaml.rb")
require 'lib/rails_reflection'

class Ya2YAML
  private
	def is_one_plain_line?(str)
		# YAML 1.1 / 4.6.11.
		str !~ /^([\-\?:,\[\]\{\}\#&\*!\|>'"%@`\s]|---|\.\.\.)/    &&
		str !~ /[:\#\r\n\t\[\]\{\},]/                              && # Changed \s to \r\n\t
		str !~ /#{REX_ANY_LB}/                                     
#		str !~ /^(#{REX_BOOL}|#{REX_FLOAT}|#{REX_INT}|#{REX_MERGE}
#			|#{REX_NULL}|#{REX_TIMESTAMP}|#{REX_VALUE})$/x
	end
end

class FixtureExtractor
  include RailsReflection
  
  def do_it!
    ActiveRecord::Base.establish_connection
    @names= {}

    @table_map= all_models.inject({}){|map,model| map[model.table_name]= model; map}
    @table_map.delete "bdrb_job_queues"
    @table_map.delete "scanner_errors"
    tables= @table_map.keys.sort

    tables.each_with_index do |table_name, table_index|
      puts "[#{table_index+1}/#{tables.size}] #{table_name}"
      model= @table_map[table_name]
      fixture= {}
      objs= model.find(:all)

      # Analyse associations
      # TODO has_and_belongs_to_many
      cols_to_ignore= %[created_at updated_at id]
      belongs_to_associations= {}
      model.reflections.each{|name,details|
        if details.macro == :belongs_to
          belongs_to_associations[name]= details
          cols_to_ignore<< details.primary_key_name
        end
      }

      objs.each{|obj|
        rec= {}
        obj.attributes.each{|k,v|
          unless cols_to_ignore.include?(k) or v.nil?
            rec[k]= v #.safe_to_i.safe_to_f
          end
        }
        belongs_to_associations.each{|name,details|
          a= obj.send(name)
          rec[name.to_s]= name_fixture_row(a) if a
        }
        row_name= name_fixture_row(obj)
#        p ["rec", rec]
        fixture[row_name]= rec
      }
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        file.write fixture.ya2yaml.sub(/\A---\s+/m,'')
      end
    end
  end

  def name_fixture_row(obj)
    model= obj.class
    names_for_this_model= (@names[model]||= {model.table_name.singularize => nil})

    # Check if we already have a name
    name= names_for_this_model[obj.id]
    return name if name

    # Generate a name
    name= case model.to_s
    when AudioContent.to_s
      if obj.audio_files.size == 1
        normalise_for_name obj.audio_files[0].basename.gsub(/^\d+? ?[\.-]\s*|\.[^\.]{1,5}$/,'')
      end
    when AudioFile.to_s
      normalise_for_name obj.basename.gsub(/^\d+? ?[\.-]\s*|\.[^\.]{1,5}$/,'')
    when Artist.to_s, Album.to_s, Track.to_s
      normalise_for_name obj.name
    when Disc.to_s
      name= normalise_for_name(obj.album.name)
      name= "#{name}_#{obj.order_id}" unless obj.order_id == 0
      name
    when Image.to_s
      normalise_for_name(obj.albums[0].name) if obj.albums.size > 1
    end
    name||= model.table_name.singularize

    # Suffix if it already exists
    if names_for_this_model.has_key?(name)
      i= "001"
      orig_name= name
      while names_for_this_model[name]
        name= "#{orig_name}_#{i.succ!}"
      end
    end

    # Store it
    names_for_this_model[name]= obj.id
    names_for_this_model[obj.id]= name
  end

  def normalise_for_name(str)
    str.to_s.gsub(/\s|:/,'_').underscore
  end
end

task :extract_fixtures => :environment do
  FixtureExtractor.new.do_it!
end
