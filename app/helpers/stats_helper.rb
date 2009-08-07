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

  def stats_row(key, value, value2=nil, options={})
    value2= %!<td class="v2">#{value2}</td>! if value2
    tr_class= "alt#{@alt^=1}"
    tr_class+= " #{options[:tr_class]}" if options[:tr_class]
    %!<tr class="#{tr_class}"><td class="k">#{key}</td><td class="v">#{value}</td>#{value2}</tr>!
  end

  def stats_row_percentage(key, a, b, decimal_places=0)
    v= format(a) + to_percentage(a,b,decimal_places){|p| " (#{p}%)"}
    stats_row key, v
  end

  def stats_graph(id, title, options={}, &block)
    data= @stats[id.to_sym]
    block||= method(:default_stats_label_gen).to_proc
    x= %!<table class="graph" id="#{id}">!
    x+= capture do
      stats_section(title, 3) do
        stats_graph_body(data, options, &block)
      end
    end
    x+= '</table>'
  end

  def stats_graph_body(data, options, &block)
    step= data[:step]
    m_lines= options[:m_lines]
    x= ''
    if data[nil]
      x+= stats_graph_row block.call(nil,step), data[nil], data[:max_value],
        :div_class => 'nil', :tr_class => 'nil'
    end
    i= data[:min]
    while i<= data[:max]
      x+= stats_graph_row block.call(i,step), data[i] || 0, data[:max_value],
        :tr_class => (m_lines and i % m_lines ==0) ? 'm_top' : nil
      i+= step
    end
    x
  end

  def stats_graph_row(title, value, max, options={})
    p= value == 0 ? 0 : to_percentage(value,max,0)
    div_class= %! class="#{options[:div_class]}"! if options[:div_class]
    stats_row(title, %!<div#{div_class} style="width:#{p}%">&nbsp;</div>!, value, options) + "\n"
  end

  def default_stats_label_gen(i, step)
    if i.nil?
      'Unknown'
    elsif step == 1
      i
    else
      "#{i} - #{i+step-1}"
    end
  end
end
