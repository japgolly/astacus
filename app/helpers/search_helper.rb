module SearchHelper
  extend ActiveSupport::Memoizable

  # If i is non-zero, returns
  #   <td class="abc">&nbsp;</td>
  #
  # If i is non-zero, returns
  #   nil
  def empty_cell_unless_first(i, cell_class)
    %!<td class="#{cell_class}">&nbsp;</td>! unless i == 0
  end

  def sq_field_group(title,&block)
    content= capture(&block)
    concat %!<table class="fields"><tr><th colspan="2">#{h title}</th></tr>!
    concat(content)
    concat "</table>"
  end

  def sq_generic_field(key, label_text, input_tag, options={})
    label_tag= label_tag(key, label_text)
    l_hint= "#{hint_tag options[:l_hint], :l_hint}" if options[:l_hint]
    r_hint= "#{hint_tag options[:r_hint], :r_hint}" if options[:r_hint]
    %!<tr><td class="l">#{label_tag}#{l_hint}</td><td class="f">#{input_tag}#{r_hint}</td></tr>!
  end

  def hint_tag(hint, clazz)
    image_tag('info.png', :alt => '', :class => "hint #{clazz}", :onclick => %!alert("#{escape_javascript hint}")!)
  end

  def sq_boolean_field(key, label_text, yes_label='Yes', no_label='No', yes_before_no= true)
    nada= ['', nil]
    yes= [yes_label, '1']
    no= [no_label, '0']
    option_array= yes_before_no ? [nada,yes,no] : [nada,no,yes]
    o= options_for_select option_array, @sq.params[key]
    t= select_tag key, o.gsub('</option>','&nbsp;</option>')
    sq_generic_field key, label_text, t
  end

  def sq_int_field(key, label_text, size, options={})
    options[:r_hint]= options[:hint] if options[:hint]
    t= text_field_tag key, @sq.params[key], :size => size*2+2
    sq_generic_field key, label_text, t, options
  end

  def sq_text_field(key, label_text, options={})
    options[:l_hint]= options[:hint] if options[:hint]
    t= text_field_tag key, @sq.params[key], :class => 'txt'
    sq_generic_field key, label_text, t, options
  end

  def generic_int_hint(name, a,b,c,d, more, less)
    more= more.to_s.downcase
    less= less.to_s.downcase
    examples= []
    examples<< ["#{a}-#{d}", "#{a}, #{d} or anything in between"]
    examples<< ["#{b}+", "#{b} or #{more}"]
    examples<< ["#{b}>", "#{more.titlecase} than #{b}"]
    examples<< ["#{b}=>", "#{b} or #{more}"]
    examples<< ["#{b}>=", "#{b} or #{more}"]
    examples<< ["-#{d}", "#{d} or #{less}"]
    examples<< ["<#{d}", "#{less.titlecase} than #{d}"]
    examples<< ["<=#{d}", "#{d} or #{less}"]
    len= examples.map{|e| e[0].length}.max
    examples_str= examples.map{|e| "%-#{len}s      \t(%s)" % e}.join("\n")
    %!Valid #{name} filter examples:\n#{examples_str}\n\nYou can also use any combination separated by commas. Example:\n#{a}-#{b}, #{c}, #{d}+!
  end
  memoize :generic_int_hint
end
