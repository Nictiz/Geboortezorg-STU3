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
        <xd:desc>Produces a mapping table from PWD /<xd:ref name="dataset-name" type="parameter"/> to FHIR for upload to e.g. somewhere on the <xd:a href="https://informatiestandaarden.nictiz.nl/wiki/Categorie:Mappings">Nictiz Information Standards wiki</xd:a>
            <xd:p><xd:b>Expected input</xd:b> DECOR release file containing ADA community info that holds relevant mapping information. Use tool "adarelease_2_adacommunity.xsl" (should be where you found this tool) to set set up the initial community for upload on ART-DECOR</xd:p>
            <xd:p><xd:b>History:</xd:b>
            <xd:ul>
                <xd:li>2018-06-20 version 0.1 MdG</xd:li>
            </xd:ul>
        </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="fhirmapping" select="document('../../fhirmapping.xml')"/>
    <xsl:key name="fhirmapping-lookup" match="dataset/record" use="ID"/>

    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match="dataset">
        <!-- First make a map/mapping construct -->
        <!-- Now: for all profiles with a name like bc-{...}Observation
            Might do this for Procedure and Condition as well -->
        <xsl:variable name="bc-profiles" select="distinct-values($fhirmapping/dataset/record/profile[(starts-with(text(), 'bc-') and ends-with(text(), 'Observation')) or starts-with(text(), 'bc-Disorder')]/text())"/>
        <xsl:variable name="dataset" select="."/>
        <maps>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="name"/>
            <xsl:for-each select="$bc-profiles">
                <xsl:sort select="."/>
                <xsl:variable name="bc-profile" select="."/>
                <map name="{$bc-profile}">
                    <xsl:variable name="conceptIDs" select="$fhirmapping/dataset/record[profile=$bc-profile]/ID/string()"/>
                    <xsl:for-each select="$dataset//concept[@iddisplay = $conceptIDs]">
                        <xsl:apply-templates select="." mode="makeTables"/>
                    </xsl:for-each>
                </map>
            </xsl:for-each>
        </maps>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates a table row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="concept" mode="makeTables">
        <xsl:variable name="id" select="@id/string()"/>
        <xsl:variable name="inheritId" select="./inherit/@ref/string()"/>
        <!-- For terminology, prefer Snomed or LOINC, else take the first one -->
        <xsl:variable name="terminologies" select="./terminologyAssociation[(@conceptId=$id) or (@conceptId=$inheritId)]"/>
        <xsl:variable name="terminology" select="if ($terminologies[@codeSystem='2.16.840.1.113883.6.96']) then $terminologies[@codeSystem='2.16.840.1.113883.6.96'] else if ($terminologies[@codeSystem='2.16.840.1.113883.6.1']) then $terminologies[@codeSystem='2.16.840.1.113883.6.1'] else $terminologies[1]"/>
        <!-- Get FHIR system, now SCT or LOINC or urn:oid:... -->
        <xsl:variable name="system" select="if ($terminologies[@codeSystem='2.16.840.1.113883.6.96']) then 'http://snomed.info/sct' else if ($terminologies[@codeSystem='2.16.840.1.113883.6.1']) then 'http://loinc.org' else if ($terminology) then concat('urn:oid:', $terminology/@codeSystem/string()) else ()"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping)"/>  
        <xsl:element name="mapping" namespace="">
            <xsl:attribute name="conceptId" select="$id"/>
            <xsl:attribute name="type" select="if (./@type = 'group') then 'group' else ./valueDomain/@type"/>
            <xsl:attribute name="shortId" select="tokenize(./@id, '\.')[last()]"/>
            <xsl:attribute name="name" select="./name/string()"/>
            <xsl:attribute name="system" select="$system"/>
            <xsl:attribute name="code" select="$terminology/@code/string()"/>
            <xsl:attribute name="display" select="$terminology/@displayName/string()"/>
            <xsl:attribute name="fhirtype">
                <xsl:choose>
                    <xsl:when test="valueDomain/@type='quantity'">valueQuantity</xsl:when>
                    <xsl:when test="valueDomain/@type='count'">valueQuantity</xsl:when>
                    <xsl:when test="valueDomain/@type='boolean'">valueBoolean</xsl:when>
                    <xsl:when test="valueDomain/@type='code'">valueCodeableConcept</xsl:when>
                    <xsl:when test="valueDomain/@type='datetime'">valueDatetime</xsl:when>
                    <xsl:when test="valueDomain/@type='quantity'">valueQuantity</xsl:when>
                    <xsl:when test="valueDomain/@type='ordinal'">valueCodeableConcept</xsl:when>
                    <xsl:when test="valueDomain/@type='string'">valueString</xsl:when>
                    <xsl:when test="valueDomain/@type='text'">valueString</xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="valueSet">
                <xsl:attribute name="valueSet" select="valueSet/@displayName/string()"/>
                <xsl:attribute name="valueSetId" select="valueSet/@id/string()"/>
                <xsl:attribute name="valueSetEffectiveDate" select="valueSet/@effectiveDate/string()"/>
            </xsl:if>
            <!--<xsl:if test="$fhirpattern">-->
                <xsl:attribute name="pattern" select="$fhirmapping/profile"/>
            <!--</xsl:if>-->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="node()|@*"/>

</xsl:stylesheet>
