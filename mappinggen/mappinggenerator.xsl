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
            <xd:p><xd:b>Expected input</xd:b> Mapping generated with release_2__fhirmapping</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2020-12-02 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
             
    <xd:doc>
        <xd:desc>For each record get ID, name and mapping and add mappings to profile.xml</xd:desc>
    </xd:doc>
    <xsl:template name="createMappings" match="record">
        <xsl:if test="ID='peri32-dataelement-37'">
        <xsl:variable name="ID" select="ID"/>
        <xsl:variable name="naam" select="naam"/>
        <xsl:variable name="mapping" select="mapping"/>
        <xsl:variable name="fileName" select="profile"/>
            <xsl:variable name="file" select="document(concat('../profiles/',profile,'.xml'))"/>
        <xsl:variable name="tempOutput">
            <xsl:for-each select="$file">
                <xsl:call-template name="addMappingsProfileLevel"/>    
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="finalOutput">
            <xsl:for-each select="$tempOutput">
                <xsl:call-template name="addMappingsElementLevel">
                    <xsl:with-param name="ID" select="$ID"/>
                    <xsl:with-param name="naam" select="$naam"/>
                    <xsl:with-param name="path" select="$mapping"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$finalOutput">
            <xsl:call-template name="createDocument">
                <xsl:with-param name="fileName"><xsl:value-of select="concat('generatedProfiles/',$fileName)"/></xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
        </xsl:if>
    </xsl:template>    
    
    <xd:doc>
        <xd:desc>Creates xml document for a FHIR resource</xd:desc>
    </xd:doc>
    <xsl:template name="createDocument" match="/" mode="doCreateDocument">
        <xsl:param name="fileName"></xsl:param>
        <xsl:result-document href="../profiles/{$fileName}.xml"> 
            <xsl:copy-of select="."/>
        </xsl:result-document>
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
                                <uri value="https://decor.nictiz.nl/art-decor/decor-datasets-\-peri20-?id=2.16.840.1.113883.2.4.3.11.60.90.77.1.6&amp;effectiveDate=2016-09-08T00%3A00%3A00&amp;conceptId=2.16.840.1.113883.2.4.3.11.60.90.77.2.6.4&amp;conceptEffectiveDate=2016-09-08T00%3A00%3A00" />
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
        <xsl:param name="ID"/>
        <xsl:param name="naam"/>
        <xsl:param name="path"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="doAddMappingElements">
                <xsl:with-param name="ID" select="$ID"/>
                <xsl:with-param name="naam" select="$naam"/>
                <xsl:with-param name="path" select="$path"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Add element level mappings to profile.xml</xd:desc>/>
    </xd:doc>
    <xsl:template name="addMappingsElement" match="f:element" mode="doAddMappingElements">
        <xsl:param name="ID"/>
        <xsl:param name="naam"/>
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="not(f:mapping/f:map[@value=$ID]) and f:path/@value=$path">
                <xsl:copy-of select="."/>
                <mapping>
                    <identity value="gebz-peri-v3.2" />
                    <map value="{$ID}" />
                    <comment value="{$naam}" />
                </mapping>
            </xsl:when>    
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>   
    </xsl:template>
    
</xsl:stylesheet>