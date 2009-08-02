module SearchQueryFilterResults
  ALBUM_FILTERS= {
    {:artist => 'RCupIN'} => %w[in_absentia],
    {:album => 'in'} => %w[6doit in_absentia],
    {:album => 'in', :artist => 'dream'} => %w[6doit],
    {:track => 'y'} => %w[still_life in_absentia],
  }.freeze unless const_defined?(:ALBUM_FILTERS)
end
