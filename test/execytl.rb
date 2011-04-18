require 'lib/ytl'
p YTL::reduced_main("1", {})
p YTL::reduced_main("1 + 1", {})
p YTL::reduced_main("2 + 2", {})
p YTL::reduced_main("[[1, 2, 3], 4][0]", {})
