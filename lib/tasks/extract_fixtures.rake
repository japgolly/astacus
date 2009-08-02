desc 'Create YAML test fixtures from data in an existing database.  
Defaults to development database.  Set RAILS_ENV to override.'

#require 'Ya2YAML'
require File.join(File.dirname(__FILE__),"../../vendor/ya2yaml.rb")
require 'lib/rails_reflection'

class FixtureExtractor
  include RailsReflection
  OUTPUT_DIR= "#{RAILS_ROOT}/test/fixtures/extracted"

  # This is the entry point
  def do_it!
    ActiveRecord::Base.establish_connection
    Dir.mkdir(OUTPUT_DIR) unless File.exists?(OUTPUT_DIR)
    @names= {}

    # Find tables/models to extract
    @table_map= all_models.inject({}){|map,model| map[model.table_name]= model; map}
    @table_map.delete "bdrb_job_queues"
    @table_map.delete "scanner_errors"
    @table_map.delete "scanner_logs"
    tables= @table_map.keys.sort

    # Extract each table
    tables.each_with_index do |table_name, table_index|
      puts "[#{table_index+1}/#{tables.size}] #{table_name}"
      model= @table_map[table_name]
      fixture= {}

      # Analyse associations
      cols_to_ignore= %[created_at updated_at id]
      belongs_to_associations= {}
      habtm_associations= {}
      model.reflections.each{|name,details|
        case details.macro
        when :belongs_to
          belongs_to_associations[name]= details
          cols_to_ignore<< details.primary_key_name
        when :has_and_belongs_to_many
          habtm_associations[name]= details if model == Track # TODO has_and_belongs_to_many only enabled for Track
        end
      }

      # Start extraction...
      objs= model.find(:all, :order => :id)
      objs.each{|obj|
        rec= {}
        # Set simple attributes
        obj.attributes.each{|k,v|
          unless cols_to_ignore.include?(k) or v.nil?
            rec[k]= v
          end
        }
        # Set belongs_to associations
        belongs_to_associations.each{|name,details|
          a= obj.send(name)
          rec[name.to_s]= name_fixture_row(a) if a
        }
        # Set habtm associations
        habtm_associations.each{|name,details|
          coll= obj.send(name)
          rec[name.to_s]= coll.map{|a| name_fixture_row(a)} unless coll.empty?
        }
        # Save row
        row_name= name_fixture_row(obj)
        fixture[row_name]= rec
      }
      # Create fixture file
      yml= fixture.ya2yaml.sub(/\A---\s+/m,'')
      yml= yml.split(/[\r\n]+/).reject{|l| l =~ /^\s*$/}.join("\n")+"\n"
      File.open("#{OUTPUT_DIR}/#{table_name}.yml", 'w') do |file|
        file.write yml
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
      normalise_for_name obj.audio_files[0].basename.gsub(/^\d+? ?[\.-]\s*|\.[^\.]{1,5}$/,'') if obj.audio_files.size == 1
    when AudioFile.to_s
      normalise_for_name obj.basename.gsub(/^\d+? ?[\.-]\s*|\.[^\.]{1,5}$/,'')
    when AudioTag.to_s
      normalise_for_name "#{obj.tracks[0].name}_#{obj.format}" if obj.tracks.size == 1
    when Artist.to_s, Album.to_s, Track.to_s
      normalise_for_name obj.name
    when Disc.to_s
      name= normalise_for_name(obj.album.name)
      name= "#{name}_#{obj.order_id}" unless obj.order_id == 0
      name
    when Image.to_s
      normalise_for_name(obj.albums[0].name) unless obj.albums.empty?
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

  # Takes a string and modifies it so that it's more appropriate as a fixture row name
  def normalise_for_name(str)
    str.to_s.gsub(/\s|:/,'_').underscore
  end
end

# Patch Ya2YAML. It's a little too strict with its escaping...
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

# Create a rake task
task :extract_fixtures => :environment do
  FixtureExtractor.new.do_it!
end
