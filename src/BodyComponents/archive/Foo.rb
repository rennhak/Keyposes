#!/usr/bin/ruby

components_h = %w[lfhd lbhd rfhd rbhd]
components_e = %w[pt26 pt27 pt28 pt29 pt30 pt31]
components_r = %w[rfin relb rsho rtoe rank rkne rhee rfwt rbwt]
components_l = %w[lfin lelb lsho ltoe lank lkne lhee lfwt lbwt]

components = ( ( components_r.concat( components_l ) ).concat( components_e ) ).concat( components_h )

components.each_with_index do |c, index|
  puts "-> #{index.to_s}   -  #{c.to_s}"
end

