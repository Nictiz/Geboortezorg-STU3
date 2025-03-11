<?xml version="1.0" encoding="UTF-8"?>
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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Updates the fhir mapping xml file for a new version of the ART-DECOR dataset by copying all concepts from the dataset and copy available mapping data from current version of the fhir mapping xml file
            <xd:p><xd:b>Expected input</xd:b> DECOR release file containing ADA community info that holds relevant mapping information. Use tool "adarelease_2_adacommunity.xsl" (should be where you found this tool) to set set up the initial community for upload on ART-DECOR</xd:p>
            <xd:p><xd:b>History:</xd:b>
            <xd:ul>
                <xd:li>2021-08-24 version 0.1 LM</xd:li>
            </xd:ul>
        </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="fhirmapping" select="document('../../fhirmapping-3-2.xml')"/>
    <xsl:key name="fhirmapping-lookup" match="dataset/record" use="ID"/>
    <xsl:key name="dataset-lookup" match="//concept" use="@iddisplay/string()"/>

    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match="dataset">
        <xsl:variable name="dataset" select="."/>
        <dataset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="$dataset//concept[@type=('group','item') and @statusCode!='cancelled']">
                <xsl:apply-templates select="." mode="createRecords"/> 
            </xsl:for-each>
        </dataset>
        <xsl:for-each select="$fhirmapping/dataset/record">
            <xsl:variable name="dataset-match" select="key('dataset-lookup', ID, $dataset)"/> 
            <xsl:if test="not($dataset-match)">
                <xsl:message>The concept for <xsl:value-of select="naam"/> with id <xsl:value-of select="ID"/> is no longer present in the dataset and is removed from the mapping file</xsl:message>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates a record for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="concept" mode="createRecords">
        <xsl:variable name="id" select="@iddisplay/string()"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping)"/>  
        <xsl:if test="not($fhirmapping)">
            <xsl:message>A new concept for <xsl:value-of select="name"/> is found with id <xsl:value-of select="$id"/> and is added to the mapping file</xsl:message>
        </xsl:if>
        <record>
            <ID><xsl:value-of select="@iddisplay/string()"/></ID>
            <naam><xsl:value-of select="name"/></naam>
            <mapping><xsl:value-of select="$fhirmapping/mapping"/></mapping>
            <profile><xsl:value-of select="$fhirmapping/profile"/></profile>
            <in><xsl:value-of select="$fhirmapping/in"/></in>
            <zib><xsl:value-of select="$fhirmapping/zib"/></zib>
            <example><xsl:value-of select="$fhirmapping/example"/></example>
            <searchurl><xsl:value-of select="$fhirmapping/searchurl"/></searchurl>
        </record>
    </xsl:template>
    
    <xsl:template match="node()|@*"/>

</xsl:stylesheet>
