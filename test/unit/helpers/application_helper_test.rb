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

  def test_format_mmss
    assert_equal '0:00', format_mmss(0)
    assert_equal '0:17', format_mmss(17.3)
    assert_equal '1:36', format_mmss(96)
    assert_equal '140:03', format_mmss(60.0 * 140 + 3.1)
  end

  def test_to_percentage
    {
      [0,0] => '',
      [0,5] => '',
      [0,5,1] => '',
      [5,5] => '100',
      [5,5,1] => '100',
      [4,5] => '80',
      [4,5,0] => '80',
      [4,5,1] => '80.0',
      [2,3] => '67',
      [2,3,1] => '66.7',
      [2,3,3] => '66.667',
    }.each{|args,expected|
      assert_equal expected, to_percentage(*args), "to_percentage(#{args.join ','}) failed."
      if expected == ''
        assert_equal '', to_percentage(*args){|x| "a #{x} b"}, "to_percentage(#{args.join ','}) with a block failed."
      else
        assert_equal "a #{expected} b", to_percentage(*args){|x| "a #{x} b"}, "to_percentage(#{args.join ','}) with a block failed."
      end
    }
  end

  def test_format_duration
    assert_equal '0:01', format_duration(1)
    assert_equal '1:03', format_duration(63)
    assert_equal '10:03', format_duration(603)
    assert_equal '59:58', format_duration(59 * 60 + 58)
    assert_equal '1:00:01', format_duration(3601)
    assert_equal '1:01:03', format_duration(3600 + 63)
    assert_equal '1:10:03', format_duration(3600 + 603)
    assert_equal '1:59:58', format_duration(3600 + 59 * 60 + 58)
    assert_equal '23:59:58', format_duration(23 * 3600 + 59 * 60 + 58)

    hms= 23 * 3600 + 59 * 60 + 58
    assert_equal '1 day, 0:00:01', format_duration(1.day.to_i + 1)
    assert_equal '1 day, 23:59:58', format_duration(1.day + hms)
    assert_equal '2 days, 23:59:58', format_duration(2.day + hms)
    assert_equal '1 week, 23:59:58', format_duration(1.week + hms)
    assert_equal '2 weeks, 3 days, 23:59:58', format_duration(2.weeks + 3.days + hms)
    assert_equal '4 months, 23:59:58', format_duration(4 * 4.weeks + hms)
    assert_equal '2 years, 3 weeks, 23:59:58', format_duration(2 * 52.weeks + 3.weeks + hms)
  end
end
