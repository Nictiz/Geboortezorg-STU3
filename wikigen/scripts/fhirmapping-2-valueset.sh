current=`dirname $0`
java -jar "$current/../../../YATC-tools/saxon/saxon.jar" -xsl:"$current/fhirmapping-2-valueset.xsl" "$current/../../fhirmapping-3-2.xml"  outputdir=$current 
output=`realpath "${current}/../../profiles/ValueSets/"`

echo Overwriting existing ValueSets/bc*.xml with generated ValueSets/bc*.xml 
mv ${current}/ValueSets/bc*.xml $output
rm -rf $current/ValueSets