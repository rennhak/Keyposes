CONVERT = /usr/bin/convert -density 300x300 -quality 100

all: curvature.eps curvature.png ekin.eps ekin.png velocity.eps velocity.png flatclean

curvature.png: curvature.eps
ekin.png: ekin.eps
velocity.png: velocity.eps

curvature.eps: curvature.gp
	gnuplot curvature.gp

ekin.eps: ekin.gp
	gnuplot ekin.gp

velocity.eps: velocity_plot.gp
	gnuplot velocity_plot.gp

%.jpg:	%.eps
	$(CONVERT) $< $@

%.gif:	%.eps
	$(CONVERT) $< $@

%.png:	%.eps
	$(CONVERT) $< $@

%.pdf:	%.eps
	epstopdf $<

clean:
	/bin/rm -f *.eps *.gif *.jpg *.png *.pdf *.ps

flatclean:
	/bin/rm -f *.eps
