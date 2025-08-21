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
        <xd:desc>Produces valuesets from FHIR mapping
            <xd:p><xd:b>Expected input</xd:b> Reads xml files (profiles) from input directory and FHIR mapping from mapping xml file</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2020-12-02 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="inputDir" select="'../profiles/'"/>
    <xsl:variable name="outputDir" select="'../profiles/generatedProfiles/'"/>
    <xsl:variable name="mappingFile" select="document('../fhirmapping-3-2.xml')"/>
    
    <xd:doc>
        <xd:desc>
            Starts in the main template, reads collection of xml files (profiles) from input directory and calls create mappings template from here
        </xd:desc>/>
    </xd:doc>
    <xsl:template name="main" match="/">
        <xsl:for-each select="collection(concat($inputDir, '?select=*.xml'))">
            <xsl:variable name="id" select="f:StructureDefinition/f:id/@value"/>
            <xsl:result-document href="{concat($outputDir, $id, '.xml')}">
                    <xsl:call-template name="createMappings">
                        <xsl:with-param name="record"> 
                            <xsl:copy-of select="$mappingFile/dataset/record[profile=$id]"/>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:result-document>    
        </xsl:for-each>
    </xsl:template>
         
    <xd:doc>
        <xd:desc>For each record get ID, name and mapping and add mappings to profile.xml</xd:desc>
    </xd:doc>
    <xsl:template name="createMappings" match="f:StructureDefinition" mode="doCreateMappings">
        <xsl:param name="record"/>
        <xsl:variable name="tempOutput">
                <xsl:call-template name="addMappingsProfileLevel"/>    
        </xsl:variable>
        <xsl:for-each select="$tempOutput">
            <xsl:call-template name="addMappingsElementLevel">
                <xsl:with-param name="record" select="$record"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>    
       
    <xd:doc>
        <xd:desc>Add profile level mappings to profile.xml</xd:desc>/>
    </xd:doc>
    <xsl:template name="addMappingsProfileLevel" match="node() | @*" mode="doAddMappingProfile">
         <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="doAddMappingProfile">
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Add profile level mappings to profile.xml</xd:desc>/>
    </xd:doc>
    <xsl:template name="addMappingsProfile" match="f:StructureDefinition" mode="doAddMappingProfile">
        <xsl:copy>
        <xsl:choose>
            <xsl:when test="not(f:mapping/f:identity[@value='gebz-peri-v3.2'])">
                <xsl:for-each select="node() | @*">
                    <xsl:choose>
                        <xsl:when test="name(.)='kind'">
                            <mapping>
                                <identity value="gebz-peri-v3.2" />
                                <uri value="https://decor.nictiz.nl/art-decor/decor-datasets--peri20-?id=2.16.840.1.113883.2.4.3.11.60.90.77.1.6&amp;effectiveDate=2016-09-08T00%3A00%3A00&amp;conceptId=2.16.840.1.113883.2.4.3.11.60.90.77.2.6.4&amp;conceptEffectiveDate=2016-09-08T00%3A00%3A00" />
                                <name value="Geboortezorg 3.2" />
                            </mapping>
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Add element level mappings to profile.xml</xd:desc>/>
    </xd:doc>
    <xsl:template name="addMappingsElementLevel" match="node() | @*" mode="doAddMappings doAddMappingElements">
        <xsl:param name="record"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="doAddMappingElements">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Add element level mappings to profile.xml</xd:desc>/>
    </xd:doc>
    <xsl:template name="addMappingsElement" match="f:element" mode="doAddMappingElements">
        <xsl:param name="record"/>
        <xsl:variable name="this" select="."/>
        <element id="{$this/@id}">
            <xsl:copy-of select="$this/*"/>
        <xsl:for-each select="$record/record">
            <xsl:if test="not($this/f:mapping/f:map[@value=ID]) and $this/f:path/@value=mapping">
                <mapping>
                    <identity value="gebz-peri-v3.2" />
                    <map value="{ID}" />
                    <comment value="{naam}" />
                </mapping>                 
            </xsl:if>
        </xsl:for-each>
        </element>
    </xsl:template>
    
</xsl:stylesheet>