geonames2sqlite
===============

Make a single SQLite database from the following GeoNames text dump tables:

* allCountries.txt
* admin1CodesASCII.txt
* admin2Codes.txt
* featureCodes_en.txt
* hierarchy.txt
* countryInfo.txt

Note that while allCountries.geonameid is used as a foreign key for most tables,
we really ought to break up allCountries into more tables for feature codes/classes
and admin codes/names in order to use the appropriate foreign keys there.

How to Use
==========

Look up comma separated adm codes and names no lower than the current feature, along with the geonameid, name, lat, lng, modification date, etc:

|  geoname_id | place_name        | latitude | longitude | location_type_code | location_type_name                   | geoname_adm_code | geonames_adm_name                        | geonames_retrieval_time   |
|-------------|-------------------|----------|-----------|--------------------|--------------------------------------|------------------|------------------------------------------|---------------------------|
|  1125426    | Shighnan District | 37.61667 | 71.45     | ADM2               | second-order administrative division | AF,01,1125426    | Afghanistan,Badakhshan,Shighnan District | 2013-04-27T00:00:00+0000  |


Example SQLite flavored SQL to do so:

```sql
SELECT
    a.geonameid AS geoname_id,
    a.name AS place_name,
    a.latitude,
    a.longitude,
    f.code AS location_type_code,
    f.name AS location_type_name,
    CASE 
        WHEN f.code = 'ADM1' THEN group_concat( a.countrycode || ',' || adm1.adm1_code ) 
        WHEN f.code = 'ADM2' THEN group_concat( a.countrycode || ',' || adm1.adm1_code || ',' || adm2.adm2_code )
        ELSE group_concat( a.countrycode || ',' || a.admin1code || ',' || a.admin2code || ',' || a.admin3code || ',' || a.admin4code )
    END AS geoname_adm_code,
    CASE
        WHEN f.code = 'ADM1' THEN group_concat( cc.Country || ',' || adm1.adm1_name )
        WHEN f.code = 'ADM2' THEN group_concat( cc.Country || ',' || adm1.adm1_name || ',' || adm2.adm2_name ) 
        ELSE 
		CASE
			WHEN adm1.adm1_name IS NULL AND adm2.adm2_name IS NULL THEN cc.Country
			WHEN adm1.adm1_name IS NOT NULL AND adm2.adm2_name IS NULL THEN group_concat( cc.Country || ',' || adm1.adm1_name )
			WHEN adm1.adm1_name IS NOT NULL AND adm2.adm2_name IS NOT NULL THEN group_concat( cc.Country || ',' || adm1.adm1_name || ',' || adm2.adm2_name )
			ELSE cc.Country
		END
    END AS geonames_adm_name,
    modificationdate || 'T00:00:00+0000' AS geonames_retrieval_time
    FROM
        allCountries AS a
    LEFT JOIN featurecodes_en AS f 
        ON a.featurecode = f.code
    LEFT JOIN admin1codesascii AS adm1 
        ON adm1.adm0_code = a.countrycode AND adm1.adm1_code = a.admin1code
    LEFT JOIN admin2codes AS adm2 
        ON adm2.adm0_code = a.countrycode AND adm2.adm1_code = a.admin1code AND adm2.adm2_code = a.admin2code
    LEFT JOIN countryInfo AS cc 
        ON cc.ISO = a.countrycode
    WHERE
        a.geonameid =  '1125426'
    GROUP BY a.geonameid
;
```


Nota Bene
=========

As of 2014-10-01 countryInfo.txt has an incorrect number of fields for Åland Islands due to a double tab.

TODO
====

SpatiaLite?  Unclear if this would be helpful if not paired with other geometries like admin boundaries and roads.
