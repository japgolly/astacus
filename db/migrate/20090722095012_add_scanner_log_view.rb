class AddScannerLogView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      create view v_scanner_logs as
      select sl.*
        , round((case when ended is null then utc_timestamp() else ended end)-started,1) duration
        , case when files_scanned is null then 0 else round(files_scanned/((case when ended is null then utc_timestamp() else ended end)-started)*3600) end fph
        , l.dir
      from scanner_logs sl, locations l
      where sl.location_id=l.id;
    EOS
  end

  def self.down
    execute "drop view v_scanner_logs;"
  end
end
