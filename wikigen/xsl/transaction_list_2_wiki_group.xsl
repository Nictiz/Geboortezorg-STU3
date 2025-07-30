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
        <xd:desc>Produces a wiki table from FHIR mapping/<xd:ref name="dataset-name" type="parameter"/> to FHIR for upload to e.g. somewhere on the <xd:a href="https://informatiestandaarden.nictiz.nl/wiki/Categorie:Mappings">Nictiz Information Standards wiki</xd:a>
            <xd:p><xd:b>Expected input</xd:b> Mapping generated with release_2__fhirmapping</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2020-05-26 version 0.1 MdG</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:include href="add-type.xsl"/>
    
    <xsl:param name="mode" select="'transaction-table'"/>
    <!--<xsl:param name="mode" select="'valuation-table'"/>-->
    <xsl:param name="pattern" select="'bc-DeliveryObservation'"></xsl:param>
    
    <xd:doc>
        <xd:desc>Start table for  the root concepts of the dataset</xd:desc>
    </xd:doc>
    <xsl:template match="maps">
        <xsl:for-each select="map"><xsl:text>=Addendum </xsl:text><xsl:value-of select="name"/><xsl:text>=
{{IssueBox|Generated code, do not change by hand}}
=</xsl:text><xsl:value-of select="@shortName"/><xsl:text>=
&lt;section begin=transaction /&gt;
{| class="wikitable" 
| style="background-color: #1F497D;; color: white; font-weight: bold; text-align:center;"  colspan="13" | PWD 3.2 to FHIR
|-style="background-color: #1F497D;; color: white; text-align:left;"
|| Profile
|| Mapping
|| Example
<!--|| Search URL--></xsl:text>
            
            <!-- groeperen op profiel -->
            <xsl:for-each-group select="mapping" group-by="@pattern">
            
                <!-- De rest van de rijen -->
                <xsl:apply-templates select="." mode="wiki"/>
            
            </xsl:for-each-group>
                       
            <!-- Tabel afsluiten -->
            <xsl:text>
|}
&lt;section end=transaction /&gt;
</xsl:text>
        </xsl:for-each>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates a mapping row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="mapping[@pattern]" mode="wiki">
        <xsl:variable name="bgcolor" select="if (@level='1') then '#E8D7BE;' else if (./@type = 'group') then '#E3E3E3;' else ()"/>
        <xsl:text>
|-</xsl:text>
        <!-- Type dependent stuff -->
        <xsl:choose>
            <xsl:when test="./@type = 'group'">
                <xsl:text>style="vertical-align:top; </xsl:text>
                <xsl:if test="$bgcolor"> background-color: <xsl:value-of select="$bgcolor"/>"</xsl:if>
            </xsl:when>
        </xsl:choose>
        <xsl:text>
|</xsl:text>
        <xsl:choose>
            <xsl:when test="@bc-pattern='true'">
                <xsl:text>[[Gebz:FHIR_</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>]]</xsl:text>
            </xsl:when>
            <xsl:when test="@pattern and starts-with(@pattern, 'bc-')">
                <xsl:text>{{Simplifier|http://nictiz.nl/fhir/StructureDefinition/</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=1.3.3|title=</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <xsl:when test="@pattern and starts-with(@pattern, 'nl-')">
                <xsl:text>{{Simplifier|http://fhir.nl/fhir/StructureDefinition/</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>|nictiz.fhir.nl.stu3.zib2017|pkgVersion=2.2.10|title=</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <xsl:when test="@pattern and starts-with(@pattern, 'zib-')">
                <xsl:text>{{Simplifier|http://nictiz.nl/fhir/StructureDefinition/</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>|nictiz.fhir.nl.stu3.zib2017|pkgVersion=2.2.10|title=</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>}}</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>
||</xsl:text>
        <xsl:choose>
            <xsl:when test="contains(@mapping,'.')">
                <xsl:value-of select="substring-before(@mapping,'.')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@mapping"/>
            </xsl:otherwise>
        </xsl:choose>   
        <xsl:text>
||</xsl:text>
        <xsl:if test="@example and @example!=''">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="@example"/>
            <xsl:text> example]</xsl:text>
        </xsl:if>
        <xsl:text>
<!--||--></xsl:text>
<!--        <xsl:for-each select="distinct-values(current-group()/search)"> -->      
<!--                    <xsl:text>-->
<!--* </xsl:text><xsl:value-of select="."/> -->
        <!--</xsl:for-each>--> 
    </xsl:template>
</xsl:stylesheet>
