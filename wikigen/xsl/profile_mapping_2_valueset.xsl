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
        <xd:desc>Start ValueSet for each map</xd:desc>
    </xd:doc>
    <xsl:template match="map" name="mapsToValueSet" as="element()*">
        <ValueSet xmlns="http://hl7.org/fhir">
            <id value="{@name}-code"/>
            <meta>
                <profile value="http://hl7.org/fhir/StructureDefinition/shareablevalueset"/>
            </meta>
            <url value="http://nictiz.nl/fhir/ValueSet/{@name}-code"/>
            <version value="1.0.0"/>
            <name value="{@name}-code"/>
            <title value="{@name}-code"/>
            <status value="draft"/>
            <experimental value="false"/>
            <publisher value="Nictiz"/>
            <description value="{@name}-code"/>
            <immutable value="false"/>
            <copyright value="This artefact includes content from SNOMED Clinical Terms® (SNOMED CT®) which is copyright of the International Health Terminology Standards Development Organisation (IHTSDO). Implementers of these artefacts must have the appropriate SNOMED CT Affiliate license - for more information contact http://www.snomed.org/snomed-ct/getsnomed-ct or info@snomed.org."/>
            <compose>             
                <xsl:variable name="mappings" select="mapping"/>
                <xsl:for-each select="distinct-values(mapping/@system)">
                    <xsl:variable name="system" select="."/>
                    <xsl:if test="$system!=''"> 
                        <include>
                            <system value="{$system}"/>
                            <xsl:for-each select="distinct-values($mappings[@system=$system]/@code)">
                                <xsl:variable name="code" select="."/>
                                <xsl:for-each select="$mappings[@system=$system and @code=$code][1]"> <!-- nodig voor het ontdubbelen van codes -->
                                    <xsl:call-template name="mappingsToConcepts"/>
                                </xsl:for-each>
                            </xsl:for-each>
                        </include>
                    </xsl:if>
                </xsl:for-each>   
            </compose>    
        </ValueSet>       
    </xsl:template>

    <xsl:template match="mapping" name="mappingsToConcepts" as="element()*">
        <xsl:if test="@code!=''"> 
            <concept>
                <code value = "{@code}"/>
                <display value = "{@display}"/>
            </concept>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates xml document</xd:desc>
    </xd:doc>
    <xsl:template match="maps">
        <xsl:for-each select="map">
            <xsl:result-document href="../../profiles/ValueSets/generated/{@name}-code.xml"> 
                <xsl:call-template name="mapsToValueSet"/>
            </xsl:result-document>          
        </xsl:for-each>
    </xsl:template> 
    
</xsl:stylesheet>