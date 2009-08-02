module SearchQueryFilterResults
  unless const_defined?(:ALBUM_FILTERS)
    ALBUM_FILTERS= {
      {:artist => 'RCupIN'} => %w[in_absentia],
      {:album => 'in'} => %w[6doit in_absentia],
      {:album => 'in', :artist => 'dream'} => %w[6doit],
      {:track => 'y'} => %w[still_life in_absentia],

      {:year => '1994'} => %w[ponk],
      {:year => '1994-1998'} => %w[ponk still_life],
      {:year => '1970 - 2000'} => %w[ponk still_life],
      {:year => '2010-2000'} => %w[6doit in_absentia],
      {:year => '1998+'} => %w[still_life 6doit in_absentia],
      {:year => '-1998'} => %w[ponk still_life],
      {:year => '1994,2002'} => %w[ponk 6doit in_absentia],
      {:year => '-1990, 1994, 2000+'} => %w[ponk 6doit in_absentia],
      {:year => '1992-1995, 1990, 2002'} => %w[ponk 6doit in_absentia],
    }.freeze
  end
end