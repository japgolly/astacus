require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  def test_format_nil
    assert_nil format(nil)
  end

  def test_format_fixnum
    assert_equal '0', format(0)
    assert_equal '1,234,567,890', format(1234567890)
    assert_equal '234,567,890', format(234567890)
    assert_equal '34,567,890', format(34567890)
    assert_equal '4,567,890', format(4567890)
    assert_equal '567,890', format(567890)
    assert_equal '67,890', format(67890)
    assert_equal '7,890', format(7890)
    assert_equal '890', format(890)
    assert_equal '90', format(90)
    assert_equal '1', format(1)
    assert_equal '-1,234,567,890', format(-1234567890)
    assert_equal '-234,567,890', format(-234567890)
    assert_equal '-34,567,890', format(-34567890)
    assert_equal '-4,567,890', format(-4567890)
    assert_equal '-567,890', format(-567890)
    assert_equal '-67,890', format(-67890)
    assert_equal '-7,890', format(-7890)
    assert_equal '-890', format(-890)
    assert_equal '-90', format(-90)
    assert_equal '-1', format(-1)
  end

  def test_format_bytes
    assert_equal '2 bytes', format_bytes(2)
    assert_equal '1.0 KB (1,024 bytes)', format_bytes(1.kilobyte)
    assert_equal '1.0 MB (1,048,576 bytes)', format_bytes(1.megabyte)
    assert_equal '1.00 GB (1,073,741,824 bytes)', format_bytes(1.gigabyte)
    assert_equal '1.000 TB (1,099,511,627,776 bytes)', format_bytes(1.terabyte)
  end
end
