class AddScannerLogView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      create view v_scanner_logs as
      select sl.*
        , round(timestampdiff(second,started,case when ended is null then utc_timestamp() else ended end)/60,1) duration_min
        , round(timestampdiff(second,started,case when ended is null then utc_timestamp() else ended end)/3600,2) duration_hr
        , case when files_scanned is null then 0
          else round(files_scanned*3600/timestampdiff(second,started,case when ended is null then utc_timestamp() else ended end))
          end fph
        , l.dir
      from scanner_logs sl, locations l
      where sl.location_id=l.id;
    EOS
  end

  def self.down
    execute "drop view v_scanner_logs;"
  end
end
