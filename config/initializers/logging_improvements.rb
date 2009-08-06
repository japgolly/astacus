# trim blob logging
class ActiveRecord::ConnectionAdapters::MysqlAdapter
  def format_log_entry(message, dump = nil)
    if dump
      dump = dump.gsub(/x'([^']+?)'/) do |blob|
        (blob.length > 64) ? "x'#{$1[0,32]}... (#{blob.length} bytes)'" : $0
      end
    end
    super
  end
end
