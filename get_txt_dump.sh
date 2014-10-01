#!/bin/bash

# download txt dump files from geonames
# hope these URLs haven't changed!

outdir=input/

# see if you have the contents of the zip already. contents are assumed to be named in the style "$( basename foo.zip .zip).txt"
# user arg is url  
function get_zip_if_not_exists
{
	zip=$( echo $1 | grep -oE "[^/]*$" )
	txt=$( basename $zip .zip ).txt
	if [[ -z $( find $outdir -maxdepth 1 -type f -iregex ".*${txt}$" ) ]]; then
		wget -c -np -P $outdir $1
		cd $outdir
		unzip $zip
		rm $zip
		cd - 1>/dev/null
	else
		echo -e "Geonames $( basename $zip .zip ).txt is already under the output directory!\nIf this is not the right file, remove it and run this script again."
	fi
}

get_zip_if_not_exists http://download.geonames.org/export/dump/hierarchy.zip
get_zip_if_not_exists http://download.geonames.org/export/dump/allCountries.zip

tmp=$(mktemp)
# NB: allCountries.zip and hierarchy.zip are missing from this list because they're handled by functions above
cat > $tmp <<EOF
http://download.geonames.org/export/dump/featureCodes_en.txt
http://download.geonames.org/export/dump/countryInfo.txt
http://download.geonames.org/export/dump/admin1CodesASCII.txt
http://download.geonames.org/export/dump/admin2Codes.txt
EOF

wget -c -np -P $outdir -i $tmp
