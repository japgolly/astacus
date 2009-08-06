module StatsHelper
  def stats_section(title,&block)
    if @first_section.nil?
      @first_section= false
    else
      concat %!<tr class="sep"><th colspan="2">&nbsp;</th></tr>!
    end
    @alt= 1
    content= capture(&block)
    concat %!<tr class="section"><th colspan="2">#{h title}</th></tr>!
    concat(content)
  end

  def stats_row(key,value)
    %!<tr class="alt#{@alt^=1}"><td class="k">#{key}</td><td class="v">#{value}</td></tr>!
  end

  def stats_row_percentage(key, a, b, decimal_places=0)
    v= format(a) + to_percentage(a,b,decimal_places){|p| " (#{p}%)"}
    stats_row key, v
  end
end
