all:
	rm -f input/*
	rm -f output/*
	./get_txt_dump.sh
	./geonames2sqlite.sh input/ output/geonames.sqlite
