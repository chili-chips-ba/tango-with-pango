# ----------------------------------------
# Created on: Sun Oct  8 15:08:27 2023
# Auto generated by Pango
# ----------------------------------------

vsim  -voptargs="+acc" -L work -L usim -L adc -L ddrc -L ddrphy -L hsst_e2 -L iolhr_dft -L ipal_e1 -L pciegen2 tb_lcd_rgb_colorbar usim.GTP_GRS
add wave *
view wave
view structure
view signals

run 1000ns

# ----------------------------------------
