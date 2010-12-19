module StatsHelper

  def stats_section(title, colspan=2, &block)
    content= capture(&block)
    pre_section(colspan) + %!<tr class="section"><th colspan="#{colspan}">#{h title}</th></tr>#{content}!.html_safe
  end

  def pre_section(colspan)
    @alt= 1
    if @first_section.nil?
      @first_section= false
      ''
    else
      %!<tr class="sep"><th colspan="#{colspan}">&nbsp;</th></tr>!
    end.html_safe
  end

  def stats_row(key, value, value2=nil, options={})
    value2= %!<td class="v2">#{value2}</td>! if value2
    tr_class= "alt#{@alt^=1}"
    tr_class+= " #{options[:tr_class]}" if options[:tr_class]
    %!<tr class="#{tr_class}"><td class="k">#{key}</td><td class="v">#{value}</td>#{value2}</tr>!.html_safe
  end

  def stats_row_percentage(key, a, b, decimal_places=0)
    v= format(a) + to_percentage(a,b,decimal_places){|p| " (#{p}%)"}
    stats_row key, v
  end

  def stats_graph(id, title, options={}, &block)
    data= @stats[id.to_sym]
    block||= method(:default_stats_label_gen).to_proc

    # Graph header
    x= %!<div class="graph" id="#{id}">!
    x+= %!<table class="graph_header">!
    x+= pre_section(2)
    x+= %!<tr class="section"><th class="title">#{h title}</th>!

    # Render the Show/Hide button
    hidden= options[:hide]
    hide_lnk_txt,show_lnk_txt = 'Hide','Show'
    body_id= "#{id}_body"
    hide_id= "#{id}_hide"
    hide_lnk= link_to_function hidden ? show_lnk_txt : hide_lnk_txt, %!
        var body = $('#{body_id}');
        Element.update('#{hide_id}', body.visible() ? '#{show_lnk_txt}' : '#{hide_lnk_txt}');
        body.toggle();
      !.gsub(/^\s+/,'').gsub(/[\r\n]+/,''), :id => hide_id
    x+= %!<th class="showhide">#{hide_lnk}</th></tr></table>!

    # Graph body
    x+= %!<table id="#{body_id}" class="graph_body" #{'style="display:none"' if hidden}>!
    x+= stats_graph_body(data, options, &block)
    x+= '</table></div>'
    x.html_safe
  end

  def stats_graph_body(data, options, &block)
    step= data[:step]
    m_lines= options[:m_lines]
    x= ''.html_safe
    if data[nil]
      x+= stats_graph_row get_stats_label(block,nil,step,options), data[nil], data[:max_value],
        :div_class => 'nil', :tr_class => 'nil'
    end
    i= data[:min]
    while i<= data[:max]
      x+= stats_graph_row get_stats_label(block,i,step,options), data[i] || 0, data[:max_value],
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

  def get_stats_label(gen_proc, i, step, options)
    if ex= options[:exceptions]
      label= ex[i] || ex[i.to_s]
      return label if label
    end
    gen_proc.call i, step
  end

  def default_stats_label_gen(i, step)
    if i.nil?
      'Unknown'
    elsif step == 1
      i.to_s
    else
      "#{i} - #{i+step-1}"
    end.html_safe
  end
end
