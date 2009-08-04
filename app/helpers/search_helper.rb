module SearchHelper

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

  def sq_generic_field(key, label_text, input_tag)
    label_tag= label_tag(key, label_text)
    %!<tr><td class="l">#{label_tag}</td><td class="f">#{input_tag}</td></tr>!
  end

  def sq_boolean_field(key, label_text, yes_label, no_label, yes_before_no= true)
    nada= ['', nil]
    yes= [yes_label, '1']
    no= [no_label, '0']
    option_array= yes_before_no ? [nada,yes,no] : [nada,no,yes]
    o= options_for_select option_array, @sq.params[key]
    t= select_tag key, o.gsub('</option>','&nbsp;</option>')
    sq_generic_field key, label_text, t
  end

  def sq_int_field(key, label_text, size)
    t= text_field_tag key, @sq.params[key], :size => size*2+2
    sq_generic_field key, label_text, t
  end

  def sq_text_field(key, label_text)
    t= text_field_tag key, @sq.params[key], :class => 'txt'
    sq_generic_field key, label_text, t
  end
end
