module SearchQueryFilterResults
  unless const_defined?(:ALBUM_FILTERS)
    ALBUM_FILTERS= {
      {:artist => 'RCupIN'} => %w[in_absentia],

      {:album => 'in'} => %w[6doit in_absentia],

      {:track => 'y'} => %w[still_life in_absentia devdas],

      {:year => '1994'} => %w[ponk],
      {:year => '1994-1998'} => %w[ponk still_life],
      {:year => '1970 - 2000'} => %w[ponk still_life],
      {:year => '2010-2000'} => %w[6doit in_absentia devdas],
      {:year => '1998+'} => %w[still_life 6doit in_absentia devdas],
      {:year => '-1998'} => %w[ponk still_life],
      {:year => '1994,2002'} => %w[ponk 6doit in_absentia],
      {:year => '-1990, 1994, 2000+'} => %w[ponk 6doit in_absentia devdas],
      {:year => '1992-1995, 1990, 2002'} => %w[ponk 6doit in_absentia],

      {:albumart => '0'} => %w[6doit still_life],
      {:albumart => '1'} => %w[ponk in_absentia devdas],

      {:discs => '1'} => %w[ponk in_absentia devdas],
      {:discs => '2'} => %w[6doit],
      {:discs => '3'} => %w[still_life],
      {:discs => ' 2+'} => %w[6doit still_life],
      {:discs => ' 3  - 4'} => %w[still_life],

      {:disc => 'disc 2'} => %w[6doit still_life],
      {:disc => '3'} => %w[still_life],

      {:location => 'main'} => %w[6doit still_life],
      {:location => 'c_downloads'} => %w[ponk],
      {:location => 'd_downloads'} => %w[in_absentia],
      {:location => 'main d_downloads'} => %w[6doit still_life in_absentia],
      {:location => '!main'} => %w[ponk in_absentia devdas],
      {:location => '!c_downloads,d_downloads'} => %w[6doit still_life devdas],

      {:va => '0'} => %w[ponk 6doit in_absentia still_life],
      {:va => '1'} => %w[devdas],

      # combinations
      {:album => 'in', :artist => 'dream'} => %w[6doit],
      {:year => '2000+', :albumart => '1'} => %w[in_absentia devdas],
    }.freeze
  end
end