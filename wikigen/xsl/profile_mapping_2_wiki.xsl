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
|| Reference
|| Profile
|| System 
|| Code
|| Display </xsl:text>           
<!--<xsl:if test="contains(@name,'Observation')">-->
    <xsl:text>
|| FHIR element </xsl:text>
<!--</xsl:if>-->
    <xsl:text>
|| ValueSet </xsl:text>
<!-- deze is altijd leeg en alleen van toepassing op observation, voor nu weglaten -->
<!--  || unit -->
         
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
        <xsl:variable name="parent" select="@parent"/>  
        <xsl:variable name="siblings" select="preceding-sibling::*[@parent=$parent and @baseelement=false()] | following-sibling::*[@parent=$parent and @baseelement=false()]"/>
        <xsl:text>
|-</xsl:text>
        <!-- Type dependent stuff -->
        <xsl:if test="./@type = 'group' or @baseelement=false()">
            <xsl:text>style="</xsl:text>
            <xsl:if test="./@type = 'group'">
                <xsl:text>vertical-align:top; </xsl:text>
                <xsl:if test="$bgcolor"> background-color: <xsl:value-of select="$bgcolor"/></xsl:if>
            </xsl:if>
            <xsl:if test="@baseelement=false()">font-style: italic;</xsl:if>
            <xsl:text>"</xsl:text>
        </xsl:if>
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
        <!-- Indent for additional (non-base) elements -->
        <xsl:if test="@baseelement=false()">
            <!--<xsl:for-each select="2 to xs:int(@level)">-->
                <xsl:text disable-output-escaping="yes"><![CDATA[&#160;&#160;&#160;]]></xsl:text>
            <!--</xsl:for-each>-->
        </xsl:if>
        <xsl:value-of select="@name"/>
        <xsl:text>
||</xsl:text>
        <xsl:value-of select="@referenceId"/>
        <xsl:text>
||</xsl:text>
        <xsl:text>{{Simplifier|http://nictiz.nl/fhir/StructureDefinition/</xsl:text>
        <xsl:value-of select="@pattern"/>
        <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=1.3.0|title=</xsl:text>
                <xsl:value-of select="@pattern"/>
                <xsl:text>}}</xsl:text>
        <xsl:text>
||</xsl:text>
        <xsl:if test="not(@fhirtype='valueCodeableConcept') or contains(@pattern,'Observation')">
            <xsl:value-of select="@system"/>
        </xsl:if>
        <xsl:text>
||</xsl:text>
        <xsl:if test="not(@fhirtype='valueCodeableConcept') or contains(@pattern,'Observation')">
            <xsl:value-of select="@code"/>
        </xsl:if>
        <xsl:text>
||</xsl:text>
        <xsl:if test="not(@fhirtype='valueCodeableConcept') or contains(@pattern,'Observation')">
            <xsl:value-of select="@display"/>
        </xsl:if>
        <xsl:text>
||</xsl:text>
<!--        <xsl:if test="not(substring-after(@fhirelement, '.')='code') ">-->
            <xsl:value-of select="substring-after(@fhirelement, '.')"/>
        <!--</xsl:if>-->
        <xsl:text>
||</xsl:text>
        <xsl:if test="@valueSet1">
            <xsl:text>{{Simplifier|http://decor.nictiz.nl/fhir/ValueSet/</xsl:text>
            <xsl:value-of select="@valueSetId1"/>
            <xsl:text>--</xsl:text>
            <xsl:value-of select="translate(@valueSetEffectiveDate1, 'T:-', '')"/>
            <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=1.3.0|title=</xsl:text>
                <xsl:value-of select="@valueSet1"/>
                <xsl:text>}}</xsl:text>
        </xsl:if>
        <xsl:if test="@valueSet2">
            <xsl:text>{{Simplifier|http://decor.nictiz.nl/fhir/ValueSet/</xsl:text>
            <xsl:value-of select="@valueSetId2"/>
            <xsl:text>--</xsl:text>
            <xsl:value-of select="translate(@valueSetEffectiveDate2, 'T:-', '')"/>
            <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=1.3.0|title=</xsl:text>
            <xsl:value-of select="@valueSet2"/>
            <xsl:text>}}</xsl:text>
        </xsl:if>
        <xsl:if test="@valueSet3">
            <xsl:text>{{Simplifier|http://decor.nictiz.nl/fhir/ValueSet/</xsl:text>
            <xsl:value-of select="@valueSetId3"/>
            <xsl:text>--</xsl:text>
            <xsl:value-of select="translate(@valueSetEffectiveDate3, 'T:-', '')"/>
            <xsl:text>|nictiz.fhir.nl.stu3.geboortezorg|pkgVersion=1.3.0|title=</xsl:text>
            <xsl:value-of select="@valueSet3"/>
            <xsl:text>}}</xsl:text>
        </xsl:if>
<!--    deze is nu altijd leeg en alleen van toepassing bij Observation, voor nu weglaten-->
<!--        <xsl:text>
|| </xsl:text>
        <xsl:value-of select="@unit"/>-->
        <!--<xsl:value-of select="count($siblings)>0"/>-->

    </xsl:template>
    
</xsl:stylesheet>