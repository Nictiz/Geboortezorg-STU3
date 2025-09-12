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
        <xd:desc>Produces a wiki table from a map for upload to e.g. somewhere on the Nictiz Information Standards wiki
            <xd:p><xd:b>Expected input</xd:b> Map generated with retrieve_simplifier_project_resources</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2022-06-20 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:include href="add-type.xsl"/>
    
    <xsl:param name="version" select="'3.0.0'"/>
    
    <xd:doc>
        <xd:desc>Start table for  the root concepts of the dataset</xd:desc>
    </xd:doc>
    <xsl:template match="maps"><xsl:text>=Addendum FHIR mapping=
{{IssueBox|Generated code, do not change by hand}}
</xsl:text>
        <xsl:for-each select="map">
            <!-- Tabel starten -->
            <!--  <section begin=bc-PregnancyObservation /> -->
            <xsl:text>
=</xsl:text><xsl:value-of select="@name"/><xsl:text>=
&lt;section begin=</xsl:text><xsl:value-of select="@name"/>
            <!-- Header -->
            <xsl:text> /&gt;
{| class="wikitable" 
|-
|| '''Profile'''
|| '''Pattern'''
|| '''Base profile'''
|| '''FHIR resource'''
|| '''HCIM EN'''
|| '''Canonical URL'''
|| '''Description'''</xsl:text>
            <!-- De rest van de rijen -->
            <xsl:apply-templates select="profile" mode="wiki">
                <xsl:sort select="@id"/>             
            </xsl:apply-templates>
            <!-- Tabel afsluiten -->
            <xsl:text>
|}
</xsl:text>
            <!--  <section end=bc-PregnancyObservation /> -->
            <xsl:text>
&lt;section end=</xsl:text><xsl:value-of select="@name"/>
            <xsl:text> /&gt;
</xsl:text>
          </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates a mapping row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="profile[@kind='resource']" mode="wiki">
        <xsl:text>
|-
||</xsl:text>
        <xsl:text>{{Simplifier|http://nictiz.nl/fhir/StructureDefinition/</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=</xsl:text>
        <xsl:value-of select="$version"/>
        <xsl:text>|title=</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>}}</xsl:text>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="replace(@pattern,'Gebz:FHIR_IG',concat('Gebz:V',substring($version,0,4),'_FHIR_IG'))"/>
        <xsl:text>
||</xsl:text>
        <xsl:text>{{Simplifier|</xsl:text>
        <xsl:value-of select="@base"/>
        <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=</xsl:text>
        <xsl:value-of select="$version"/>
        <xsl:text>|title=</xsl:text>
        <xsl:value-of select="substring-after(@base,'StructureDefinition/')"/>
        <xsl:text>}}</xsl:text>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>
||</xsl:text>
        <xsl:text>
||</xsl:text>
        <xsl:text>&lt;nowiki&gt;http://nictiz.nl/fhir/StructureDefinition/</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>&lt;/nowiki&gt;</xsl:text>
        <xsl:text>            
||</xsl:text>
        <xsl:choose>
            <xsl:when test="contains(@description,'Pattern: [[')">
                <xsl:value-of select="substring-before(@description,'Pattern: [[')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@description"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>