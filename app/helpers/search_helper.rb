module SearchHelper

  # If i is non-zero, returns
  #   <td class="abc">&nbsp;</td>
  #
  # If i is non-zero, returns
  #   nil
  def empty_cell_unless_first(i, cell_class)
    %!<td class="#{cell_class}">&nbsp;</td>! unless i == 0
  end
end
