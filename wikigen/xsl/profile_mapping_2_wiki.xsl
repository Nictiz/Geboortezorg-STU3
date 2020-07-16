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
        <xd:desc>Produces a wiki table from FHNIR mapping/<xd:ref name="dataset-name" type="parameter"/> to FHIR for upload to e.g. somewhere on the <xd:a href="https://informatiestandaarden.nictiz.nl/wiki/Categorie:Mappings">Nictiz Information Standards wiki</xd:a>
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
| style="background-color: #1F497D;; color: white; font-weight: bold; text-align:center;"  colspan="13" | PWD 2.3 to FHIR
|-style="background-color: #1F497D;; color: white; text-align:left;"
|style="width:30px;"| Type 
|style="width:10px;"| # 
|| Concept
|| Profile
|| System 
|| Code
|| Display 
|| FHIR type 
|| system+code 
|| unit
</xsl:text>
            <!-- De rest van de rijen -->
            <xsl:apply-templates select="mapping" mode="wiki"/>
            
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
    <xsl:template match="mapping" mode="wiki">
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
        <xsl:call-template name="addType">
            <xsl:with-param name="type" select="./@type"/>
        </xsl:call-template>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@shortId"/>
        <xsl:text>
||</xsl:text>
        <!-- Indent only for entire transactions, not subsets -->
        <xsl:value-of select="@name"/>
        <xsl:text>
||</xsl:text>
        <xsl:text>[https://simplifier.net/geboortezorg-stu3/</xsl:text>
        <xsl:value-of select="@pattern"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@pattern"/>
        <xsl:text>]</xsl:text>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@system"/>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@code"/>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@display"/>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@fhirtype"/>
        <xsl:text>
||</xsl:text>
        <xsl:if test="@valueSet">
            <xsl:text>[https://simplifier.net/geboortezorg-stu3/</xsl:text>
            <xsl:value-of select="@valueSetId"/>
            <xsl:text>--</xsl:text>
            <xsl:value-of select="translate(@valueSetEffectiveDate, 'T:-', '')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@valueSet"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>
|| </xsl:text>
        <xsl:value-of select="@unit"/>
    </xsl:template>
    
</xsl:stylesheet>