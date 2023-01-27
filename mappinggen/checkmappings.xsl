<!--
Copyright © Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->

<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
        
    <xd:doc scope="stylesheet">
        <xd:desc>Checks if profile mapping corresponds with the provided mapping in the xml mapping file
            <xd:p><xd:b>Expected input</xd:b> Reads xml files (profiles) from input directory and FHIR mapping from mapping xml file</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2022-07-12 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="inputDir" select="'../profiles'"/>
    <xsl:variable name="mappingFile" select="document('../fhirmapping-3-2.xml')"/>
    
    <xd:doc>
        <xd:desc>
            Starts in the main template, reads collection of xml files (profiles) from input directory and calls create mappings template from here
        </xd:desc>/>
    </xd:doc>
    <xsl:template name="main" match="/">
        <dataset>
        <xsl:for-each select="collection(concat($inputDir, '?select=*.xml'))">
            <xsl:variable name="profileID" select="f:StructureDefinition/f:id/@value"/>
            <xsl:variable name="mappingFileRecord" select="$mappingFile/dataset/record[profile=$profileID]"/>
            <xsl:variable name="profileElement" as="element()*">
                <xsl:for-each select="//*[name()='element']">
                    <xsl:copy-of select="."/>
                </xsl:for-each>                
            </xsl:variable>            
            <xsl:variable name="profileMapping" as="element()*">
                <xsl:for-each select="//*[name()='mapping']">
                    <xsl:copy-of select="."/>
                </xsl:for-each>                
            </xsl:variable>
            <xsl:variable name="elementIDsProfile" as="xs:string*">
                <xsl:for-each select="//*[name()='mapping' and identity/@value=('gebz-peri-v3.2','gebz-peri-v3.2-ext')]">
                    <xsl:copy-of select="./f:map/@value"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="elementIDsMappingFile" select="$mappingFileRecord/ID" as="xs:string*">
            </xsl:variable>
            <xsl:variable name="allElementIDs" select="for $s in ($elementIDsMappingFile, $elementIDsProfile) return ($s)" />
            <xsl:variable name="uniqueElementIDs" select="distinct-values($allElementIDs)"/>
            <xsl:for-each select="$uniqueElementIDs">
                <xsl:variable name="elementID" select="."/>
                <xsl:variable name="elementName" select="$mappingFileRecord[ID=$elementID]/naam"/>
                <xsl:variable name="mappingComment" select="$profileMapping[f:map/@value=$elementID]/f:comment/@value"/>
                <xsl:variable name="elementMappingPath" select="$mappingFileRecord[ID=$elementID]/mapping"/>
                <xsl:variable name="profileMappingPath" select="$profileElement[f:mapping/f:map/@value=$elementID]/@id"/>
                <record>
                    <profileName value="{$profileID}"/>
                    <elementID value="{$elementID}"/>
                    <elementName value="{$elementName}"/>
                    <mappingComment value="{$mappingComment}"/>
                    <elementMapping value="{$elementMappingPath}"/>
                    <profileMapping value="{$profileMappingPath}"/>
                    <matchPath value="{$elementMappingPath=$profileMappingPath}"/>
                    <matchDescription value="{$elementName=$mappingComment}"/>
                    <countAbove1 value="{count($profileMappingPath)>1}"/>
                </record>
            </xsl:for-each>
        </xsl:for-each>
        </dataset>
    </xsl:template>
                 
</xsl:stylesheet>