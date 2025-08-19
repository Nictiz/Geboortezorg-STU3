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
            <xd:p><xd:b>Expected input</xd:b> fhirmapping(-3-2).xml</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2025-08-19 version 0.2 AH</xd:li>
                    <xd:li>2020-12-02 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="fhirVersion" select="'3.0'"/>
    <xsl:variable name="all-profiles" select="collection('../../profiles/?select=*.xml&amp;recurse=yes')//f:StructureDefinition" as="element(f:StructureDefinition)+"/>
    <xsl:variable name="fhirmapping-file" select="doc('../../fhirmapping-3-2.xml')/*" as="element()+"/>
    <xsl:variable name="ada-release-file" select="doc('../../../art_decor/projects/perinatologie-326/definitions/perinatologie-326-ada-release.xml')/*" as="element()"/>
    
    <!-- 
        <record>
            <ID>peri32-dataelement-10867</ID>
            <naam>Documentgegevens</naam>
            <mapping>DocumentReference</mapping>
            <profile>IHE.MHD.Minimal.DocumentReference</profile>
        </record>
    -->
    <!--
        <mapping>
            <identity value="gebz-peri-v3.2" />
            <map value="peri32-dataelement-8873" />
            <comment value="Identificatie zorgepisode" />
        </mapping>
    -->
    <xsl:template match="/">
        <xsl:result-document href="fhirmapping-report.html">
            <html>
                <head>
                    <title>Mapping report</title>
                    <style>* { font-family: Verdana, sans-serif; } tr:nth-child(even) { background-color: lightgrey; }</style>
                </head>
                <body>
                    <h3>Mapping report</h3>
                    <div>Generated: <xsl:value-of select="current-dateTime()"/></div>
                    <div>Mappings in fhirmapping-3-2.xml: <xsl:value-of select="count($fhirmapping-file/record)"/></div>
                    <div>Mappings in profiles/extensions: <xsl:value-of select="count($all-profiles//f:mapping[f:map/@value = 'gebz-peri-v3.2'])"/></div>
                    <table>
                        <tr>
                            <th colspan="4">Source: fhirmapping-3-2.xml</th>
                            <th>Source: ADA Release</th>
                            <th>Source: Profiles / extensions</th>
                        </tr>
                        <tr>
                            <th>Concept-ID</th>
                            <th>Concept-Name</th>
                            <th>FHIR Profile</th>
                            <th>FHIR Path</th>
                            <th>Transaction(s)</th>
                            <th>Profiles</th>
                        </tr>
                        <xsl:for-each select="$fhirmapping-file/record">
                            <xsl:variable name="mappingRecord" select="."/>
                            <xsl:variable name="datasetConcept" select="$ada-release-file//concept[@iddisplay = $mappingRecord/ID]" as="element(concept)*"/>
                            <xsl:variable name="profileMapping" select="$all-profiles//f:mapping[f:map/@value = $mappingRecord/ID]" as="element(f:mapping)*"/>

                            <!--<xsl:message>FHIR Mapping concept <xsl:value-of select="ID"/> - profile <xsl:value-of select="profile"/> - path <xsl:value-of select="mapping"/></xsl:message>
                            <xsl:choose>
                                <xsl:when test="$datasetConcept">
                                    <xsl:for-each select="$datasetConcept">
                                        <xsl:message> - <xsl:value-of select="concat(@minimumMultiplicity, '..', @maximumMultiplicity, ' ', @conformance)"/> Transaction <xsl:value-of select="ancestor-or-self::view/name"/></xsl:message>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message> - WARN No transactions</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$profileMapping">
                                    <xsl:for-each select="$profileMapping">
                                        <xsl:message> -<xsl:if test="$mappingRecord/mapping != ancestor-or-self::f:element/f:path/@value">ERROR</xsl:if> Mapping <xsl:value-of select="ancestor-or-self::f:StructureDefinition/f:name/@value"/> - path <xsl:value-of select="ancestor-or-self::f:element/f:path/@value"/></xsl:message>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message> - WARN No mappings</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>-->

                            <tr>
                                <td>
                                    <xsl:value-of select="ID"/>
                                </td>
                                <td>
                                    <xsl:value-of select="naam"/>
                                </td>
                                <td>
                                    <xsl:value-of select="mapping"/>
                                </td>
                                <td>
                                    <xsl:value-of select="profile"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="$datasetConcept">
                                            <ul>
                                                <xsl:for-each select="$datasetConcept">
                                                    <li><xsl:value-of select="concat(@minimumMultiplicity, '..', @maximumMultiplicity, ' ', @conformance)"/> Transaction <xsl:value-of select="ancestor-or-self::view/name"/></li>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:when>
                                        <xsl:when test="string-length(profile) = 0">
                                            <span style="font-style: italic;">No transactions</span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span style="color: red; font-weight: bold;">WARNING No transactions</span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="$profileMapping">
                                            <ul>
                                                <xsl:for-each select="$profileMapping">
                                                    <xsl:variable name="profileMisMatch" select="$mappingRecord/profile != ancestor-or-self::f:StructureDefinition/f:name/@value"/>
                                                    <xsl:variable name="pathMisMatch" select="$mappingRecord/mapping != ancestor-or-self::f:element/@id"/>
                                                    
                                                    <li>
                                                        <xsl:if test="$profileMisMatch or $pathMisMatch">
                                                            <span style="color: red; font-weight: bold;"><xsl:text>WARNING </xsl:text></span>
                                                        </xsl:if>
                                                        <xsl:text>Mapping </xsl:text>
                                                        <span>
                                                            <xsl:if test="$profileMisMatch">
                                                                <xsl:attribute name="style" select="'color: red; font-weight: bold;'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="ancestor-or-self::f:StructureDefinition/f:name/@value"/>
                                                        </span>
                                                        <xsl:text> - path </xsl:text>
                                                        <span>
                                                            <xsl:if test="$pathMisMatch">
                                                                <xsl:attribute name="style" select="'color: red; font-weight: bold;'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="ancestor-or-self::f:element/@id"/>
                                                        </span>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:when>
                                        <xsl:when test="starts-with(profile, 'bc-')">
                                            <span style="color: red; font-weight: bold;">WARNING No mappings</span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span style="font-style: italic;">No mappings</span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each> 
                    </table>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Start ValueSet for each map</xd:desc>
        <xd:param name="mode"/>
    </xd:doc>
    <xsl:template match="map" name="mapsToValueSet" as="element()*">
        <xsl:param name="in" as="element()+"/>
        <xsl:param name="mode" as="xs:string"/>
        <xsl:if test="$mode = ('code')"></xsl:if>
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
                    <xsl:when test="$mode = 'code'">
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
                    <xsl:when test="$mode = 'value'">
                        <!-- For .valueCodeableConcept elements include each linked valueSet -->
                        <xsl:for-each select="mapping[@fhirelement='Observation.value[x]:valueCodeableConcept']">
                            <xsl:call-template name="mappingsToIncludeVS"/>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </compose>    
        </ValueSet>       
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="mapping" name="mappingsToIncludeVS" as="element()*">
        <xsl:variable name="valueset-url" select="nf:getValueSetURL(@valueSetId1,@valueSetEffectiveDate1),nf:getValueSetURL(@valueSetId2,@valueSetEffectiveDate2),nf:getValueSetURL(@valueSetId3,@valueSetEffectiveDate3)"/>
        <xsl:for-each select="$valueset-url">
            <include>
                <valueSet value="{.}"/>
            </include>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="mapping" name="mappingsToConcepts" as="element()*">
        <xsl:if test="@code != ''"> 
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
        <xsl:for-each select="map[mapping/@system != '' or mapping/@valueSet1 != '']">
            <xsl:result-document href="../../profiles/ValueSets/generated/{@name}-code.xml"> 
                <xsl:call-template name="mapsToValueSet"/>
            </xsl:result-document>  
        </xsl:for-each>
        <xsl:for-each select="map[mapping/@fhirelement = 'Observation.value[x]:valueCodeableConcept']">
            <xsl:result-document href="../../profiles/ValueSets/generated/{@name}-value.xml"> 
                <xsl:call-template name="mapsToValueSet">
                    <xsl:with-param name="mode" select="'value'"/>
                </xsl:call-template>
            </xsl:result-document>  
        </xsl:for-each>
    </xsl:template> 
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="valueSetId"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="nf:getValueSetURL">
        <xsl:param name="valueSetId"/>
        <xsl:param name="effectiveDate"/>
        <xsl:if test="$valueSetId">
            <xsl:value-of select="concat('http://decor.nictiz.nl/fhir/', $fhirVersion, '/public/ValueSet/',$valueSetId,'--',replace($effectiveDate,'([T])|:|-',''))"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>