module SearchHelper

  # If i is non-zero, returns
  #   <td class="abc">&nbsp;</td>
  #
  # If i is non-zero, returns
  #   nil
  def empty_cell_unless_first(i, cell_class)
    %!<td class="#{cell_class}">&nbsp;</td>! unless i == 0
  end

  def sq_generic_field(key, label_text, input_tag)
    label_tag= label_tag(key, "#{label_text}:")
    %!<div>#{label_tag} #{input_tag}</div>!
  end

  def sq_boolean_field(key, label_text, yes_label, no_label, yes_before_no= true)
    nada= ['', nil]
    yes= ["#{yes_label}_nbsp", '1']
    no= ["#{no_label}_nbsp", '0']
    option_array= yes_before_no ? [nada,yes,no] : [nada,no,yes]
    o= options_for_select option_array, @sq.params[key]
    t= select_tag key, o.gsub('_nbsp','&nbsp;'), :id => nil
    sq_generic_field key, label_text, t
  end

  def sq_int_field(key, label_text, size)
    t= text_field_tag key, @sq.params[key], :id => nil, :size => size*2+2
    sq_generic_field key, label_text, t
  end

  def sq_text_field(key, label_text)
    t= text_field_tag key, @sq.params[key], :id => nil
    sq_generic_field key, label_text, t
  end
end
