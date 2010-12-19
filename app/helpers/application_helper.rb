module ApplicationHelper

  # Takes all validation errors on a model and turns it into a single sentence.
  def model_errors_to_single_string(model)
    model.errors.full_messages.join("\n\n")
  end

  # Returns a javascript tag that invokes a remote call after a certain amount of time.
  # Takes the same args as periodically_call_remote.
  def delayed_call_remote(*args)
    # TODO replace this
    periodically_call_remote(*args).sub(/(function\s*?\(\)\s*?\{)/,'\1this.stop(); ')
  end

  # Formats any generic object as follows
  # * Integers get commas every digits.
  def format(v)
    case v
    when nil then nil
    when Fixnum, Bignum
      if (str= v.to_s) =~ /^(.*?\d)(\d{3}+)$/
        a,b = $1,$2
        b.gsub! /(\d{3})/,',\1'
        a + b
      else
        str
      end
    else raise "Cannot format #{v.class}: #{v.inspect}"
    end.html_safe
  end

  # Returns human-friendly string representation of a number of bytes.
  # Eg. "24.7 MB"
  def format_bytes(v, display_exact_also= :txt)
    raise if v < 0
    res= if v >= 1.terabytes
      "%.3f TB" % [v.to_f / 1.terabytes]
    elsif v >= 1.gigabytes
      "%.2f GB" % [v.to_f / 1.gigabytes]
    elsif v >= 1.megabytes
      "%.1f MB" % [v.to_f / 1.megabytes]
    elsif v >= 1.kilobytes
      "%.1f KB" % [v.to_f / 1.kilobytes]
    else
      "#{v} bytes"
    end

    res= case display_exact_also
      when :txt then "#{res} (#{format v} bytes)"
      when :div then %!#{res}<div class="exact_bytes">(#{format v} bytes)</div>!
      else raise "Unsupported value for display_exact_also: #{display_exact_also.inspect}"
      end if display_exact_also and v >= 1.kilobytes
    res.html_safe
  end

  # Takes a number of seconds and turns it into a mm:ss string.
  # Eg. 24:07
  def format_mmss(length)
    ("%d:%02d" % [length / 60, length % 60]).html_safe
  end

  def to_percentage(a, b, decimal_places=0)
    return '' if a == 0 or b == 0
    p= if a == b
      '100'
    else
      p= a.to_f * 100.0 / b
      p= (decimal_places == 0 ? p.round(0).to_i : p.round(decimal_places)).to_s
    end.html_safe
    block_given? ? yield(p) : p
  end

  def format_duration(d)
    sec= d % 60
    min= d % 3600 / 60
    hr= d % 1.day / 3600
    if d >= 1.day
      days= d % 1.week / 1.day
      weeks= d % 4.weeks / 1.week
      months= d % 52.weeks / 4.weeks
      years= d / 52.weeks
      sprintf "#{fd_pluralize 'year',years}#{fd_pluralize 'month',months}#{fd_pluralize 'week',weeks}#{fd_pluralize 'day',days}%d:%02d:%02d", hr, min, sec
    elsif hr != 0
      sprintf '%d:%02d:%02d', hr, min, sec
    elsif min != 0
      sprintf '%d:%02d', min, sec
    else
      sprintf '0:%02d', sec
    end.html_safe
  end

  private
    def fd_pluralize(name,value)
      value= value.to_i
      return '' if value == 0
      "#{pluralize value, name}, "
    end
end
