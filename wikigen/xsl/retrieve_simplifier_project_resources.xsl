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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Produces a mapping table from PWD /<xd:ref name="dataset-name" type="parameter"/> to FHIR for upload to e.g. somewhere on the <xd:a href="https://informatiestandaarden.nictiz.nl/wiki/Categorie:Mappings">Nictiz Information Standards wiki</xd:a>
            <xd:p><xd:b>Expected input</xd:b> DECOR release file containing ADA community info that holds relevant mapping information. Use tool "adarelease_2_adacommunity.xsl" (should be where you found this tool) to set set up the initial community for upload on ART-DECOR</xd:p>
            <xd:p><xd:b>History:</xd:b>
            <xd:ul>
                <xd:li>2022-06-20 version 0.1 LM</xd:li>
            </xd:ul>
        </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="data li ul ol div pre"/>
    
    <xd:doc>
        <xd:desc>Required: Simplifier project url</xd:desc>
    </xd:doc>
    <xsl:param name="projectUrl" select="'https://stu3.simplifier.net/geboortezorg-stu3'"/>
  
    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="url" select="document(concat($projectUrl,'/StructureDefinition?_format=xml&amp;_sort=_sort=name&amp;_count=150'))"/>
        <xsl:for-each select="$url">
        <!-- First make a map/mapping construct -->
            <maps>
                <map>
                    <name value="{$projectUrl}"/>
                        <xsl:apply-templates select="f:Bundle/f:entry/f:resource/f:StructureDefinition" mode="makeTables">
                            <xsl:sort select="f:type/@value"/>
                            <xsl:sort select="f:name/@value"/>
                        </xsl:apply-templates>
                </map>
            </maps>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates a table row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="f:StructureDefinition" mode="makeTables">
        <xsl:variable name="id" select="f:id/@value"/>  
        <xsl:variable name="pattern" select="substring-before(substring-after(f:description/@value,'[['),']]')"/>
        <xsl:variable name="patternPage" select="substring-after($pattern,'| https://informatiestandaarden.nictiz.nl/wiki/')"/>
        <xsl:variable name="patternName" select="substring-before($pattern,' |')"/>
        <xsl:element name="profile" namespace="">
            <xsl:attribute name="id" select="$id"/>
            <xsl:attribute name="url" select="f:url/@value"/>
            <xsl:attribute name="name" select="f:name/@value"/>
            <xsl:attribute name="description" select="f:description/@value"/>
            <xsl:attribute name="kind" select="f:kind/@value"/>
            <xsl:attribute name="type" select="f:type/@value"/>
            <xsl:attribute name="pattern" select="if ($pattern) then concat('[[',$patternPage,'|',$patternName,']]') else $pattern"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="node()|@*"/>

</xsl:stylesheet>
