module StatsHelper
  def stats_section(title, colspan=2, &block)
    if @first_section.nil?
      @first_section= false
    else
      concat %!<tr class="sep"><th colspan="#{colspan}">&nbsp;</th></tr>!
    end
    @alt= 1
    content= capture(&block)
    concat %!<tr class="section"><th colspan="#{colspan}">#{h title}</th></tr>!
    concat(content)
  end

  def stats_row(key, value, value2=nil)
    value2= %!<td class="v2">#{value2}</td>! if value2
    %!<tr class="alt#{@alt^=1}"><td class="k">#{key}</td><td class="v">#{value}</td>#{value2}</tr>!
  end

  def stats_row_percentage(key, a, b, decimal_places=0)
    v= format(a) + to_percentage(a,b,decimal_places){|p| " (#{p}%)"}
    stats_row key, v
  end

  def stats_graph(id, title, data, &block)
    x= %!<table class="graph" id="#{id}">!
    x+= capture do
      stats_section(title, 3) do
        stats_graph_body(data, &block)
      end
    end
    x+= '</table>'
  end

  def stats_graph_body(data, &block)
    step= data[:step]
    x= ''
    x+= stats_graph_row(block.call(nil,step), data[nil], data[:max_value], 'nil') if data[nil]
    i= data[:min]
    while i<= data[:max]
      x+= stats_graph_row(block.call(i,step), data[i] || 0, data[:max_value])
      i+= step
    end
    x
  end

  def stats_graph_row(title, value, max, div_class=nil)
    p= value == 0 ? 0 : to_percentage(value,max,0)
    div_class= %!class="#{div_class}"! if div_class
    stats_row(title, %!<div #{div_class} style="width:#{p}%">&nbsp;</div>!, value) + "\n"
  end
end
