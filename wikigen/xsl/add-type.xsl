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
    <xsl:output method="text" encoding="UTF-8"/>

    <xd:doc>
        <xd:desc>Return linked icon for datatypes if possible. Return type as-is if not.</xd:desc>
        <xd:param name="type">Required. Datatype string to link. E.g. boolean, code, date, ...</xd:param>
    </xd:doc>
    <xsl:template name="addType">
        <xsl:param name="type"/>
        <!-- Type dependent stuff -->
        <xsl:choose>
            <xsl:when test="$type = 'boolean'">
                <xsl:text>[[Bestand:BL.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'blob'">
                <xsl:text>blob </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'code'">
                <xsl:text>[[Bestand:CD.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'count'">
                <xsl:text>[[Bestand:INT.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'date'">
                <xsl:text>[[Bestand:TS.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'datetime'">
                <xsl:text>[[Bestand:TS.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'duration'">
                <xsl:text>[[Bestand:PQ.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'decimal'">
                <xsl:text>REAL </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'group'">
                <xsl:text>[[Bestand:Container.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'identifier'">
                <xsl:text>[[Bestand:II.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'quantity'">
                <xsl:text>[[Bestand:PQ.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'string'">
                <xsl:text>[[Bestand:ST.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'complex'">
                <xsl:text>[[Bestand:ANY.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'text'">
                <xsl:text>[[Bestand:ST.png|16px|link=Beschrijving_en_gebruik_datatypes]] </xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'zib'">
                <xsl:text>[[Bestand:Zib.png|30px|link=]] </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- an unknown type -->
                <xsl:value-of select="$type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
