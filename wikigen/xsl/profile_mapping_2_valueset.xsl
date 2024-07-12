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
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nf="http://www.nictiz.nl/functions" exclude-result-prefixes="#all" version="2.0">
        
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
        <xsl:param name="mode" select="'code'"/>
        <ValueSet xmlns="http://hl7.org/fhir">
            <id value="{@name}-{$mode}"/>
            <meta>
                <profile value="http://hl7.org/fhir/StructureDefinition/shareablevalueset"/>
            </meta>
            <url value="http://nictiz.nl/fhir/ValueSet/{@name}-{$mode}"/>
            <version value="1.0.0"/>
            <name value="{@name}-{$mode}"/>
            <title value="{@name}-{$mode}"/>
            <status value="draft"/>
            <experimental value="false"/>
            <publisher value="Nictiz"/>
            <description value="{@name}-{$mode}"/>
            <immutable value="false"/>
            <copyright value="This artefact includes content from SNOMED Clinical Terms® (SNOMED CT®) which is copyright of the International Health Terminology Standards Development Organisation (IHTSDO). Implementers of these artefacts must have the appropriate SNOMED CT Affiliate license - for more information contact http://www.snomed.org/snomed-ct/getsnomed-ct or info@snomed.org."/>
            <compose>             
                <xsl:variable name="mappings" select="mapping[@baseelement=true()]"/>
                <xsl:choose>
                    <xsl:when test="$mode='code'">
                        <!-- For Observations include the terminology binding on the base element -->
                        <xsl:for-each select="distinct-values(mapping[starts-with(@fhirelement,'Observation')]/@system)">
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
                        <!-- For .code elements include each linked valueSet -->
                        <xsl:for-each select="mapping[substring-after(@fhirelement,'.')='code']">
                            <xsl:call-template name="mappingsToIncludeVS"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$mode='value'">
                        <!-- For .valueCodeableConcept elements include each linked valueSet -->
                        <xsl:for-each select="mapping[@fhirelement='Observation.value[x]:valueCodeableConcept']">
                            <xsl:call-template name="mappingsToIncludeVS"/>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </compose>    
        </ValueSet>       
    </xsl:template>

    <xsl:template match="mapping" name="mappingsToIncludeVS" as="element()*">
        <xsl:variable name="valueset-url" select="nf:getValueSetURL(@valueSetId1,@valueSetEffectiveDate1),nf:getValueSetURL(@valueSetId2,@valueSetEffectiveDate2),nf:getValueSetURL(@valueSetId3,@valueSetEffectiveDate3)"/>
        <xsl:for-each select="$valueset-url">
            <include>
                <valueSet value="{.}"/>
            </include>
        </xsl:for-each>
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
        <xsl:for-each select="map[mapping/@system!='' or mapping/@valueSet1!='']">
            <xsl:result-document href="../../profiles/ValueSets/generated/{@name}-code.xml"> 
                <xsl:call-template name="mapsToValueSet"/>
            </xsl:result-document>  
        </xsl:for-each>
        <xsl:for-each select="map[mapping/@fhirelement='Observation.value[x]:valueCodeableConcept']">
            <xsl:result-document href="../../profiles/ValueSets/generated/{@name}-value.xml"> 
                <xsl:call-template name="mapsToValueSet">
                    <xsl:with-param name="mode" select="'value'"/>
                </xsl:call-template>
            </xsl:result-document>  
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:function name="nf:getValueSetURL">
        <xsl:param name="valueSetId"/>
        <xsl:param name="effectiveDate"/>
        <xsl:if test="$valueSetId">
            <xsl:value-of select="concat('http://decor.nictiz.nl/fhir/ValueSet/',$valueSetId,'--',replace($effectiveDate,'([T])|:|-',''))"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>