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

Look up pipe separated adm codes and names no lower than the current feature, along with the geonameid, name, lat, lng, modification date, etc:

```sql

```

Nota Bene
=========

As of 2014-10-01 countryInfo.txt has an incorrect number of fields for Åland Islands due to a double tab.

TODO
====

SpatiaLite?  Unclear if this would be helpful if not paired with other geometries like admin boundaries and roads.
