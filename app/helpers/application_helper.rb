# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def model_errors_to_single_string(model)
    model.errors.map{|a| "#{a[0].capitalize} #{a[1]}."}.join("\n\n")
  end

  def delayed_call_remote(*args)
    periodically_call_remote(*args).sub(/(function\s*?\(\)\s*?\{)/,'\1this.stop(); ')
  end

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
    end
  end

  def format_bytes(v, display_exact_also= true)
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
    res= "#{res} (#{format v} bytes)" if display_exact_also and v >= 1.kilobytes
    res
  end
end
