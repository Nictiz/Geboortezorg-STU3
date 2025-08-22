current=`dirname $0`
java -jar "$current/../../../YATC-tools/saxon/saxon.jar" -xsl:"$current/fhirmapping-report.xsl" "$current/../../fhirmapping-3-2.xml" outputdir=$current
