#!/bin/bash

awk -F',' '
	NR == 1 { y1=$3; x1=$4 }
	NR == 3 { y2=$3; x2=$4 }

	END{
		x_mid = (x1 + x2) / 2
		y_mid = (y1 + y2) /2

		print "Koordinat pusat:"
		print y_mid, ",", x_mid
	}
' titik-penting.txt | tee posisipusaka.txt
