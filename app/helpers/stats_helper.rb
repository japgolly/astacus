module StatsHelper
  def stat_row(key,value)
    "<tr><td>#{key}</td><td>#{value}</td></tr>"
  end

  def stat_row_percentage(key, a, b, decimal_places=0)
    v= format(a) + to_percentage(a,b,decimal_places){|p| " (#{p}%)"}
    stat_row key, v
  end
end
