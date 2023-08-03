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
        <xd:desc>Produces a FHIR QuestionnaireResponse based on the ADA dataset structure
            <xd:p><xd:b>Expected input</xd:b>ADA instance</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2023-03-31 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="../../HL7-mappings/ada_2_fhir/fhir/2_fhir_fhir_include.xsl"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
     
    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match=".[@app]">
        <xsl:variable name="dataset" select="."/>
        <xsl:variable name="datasetName" select="translate(@formName,'_','-')"/>
        <QuestionnaireResponse>    
            <id value="{$datasetName}"/>
            <questionnaire>
                <reference value="{concat('http://nictiz/fhir/StructureDefinition/dataset/',$datasetName)}"/> <!-- todo: juiste reference -->
            </questionnaire> 
            <status value="completed"/>
            <!-- NTH: subject & context-->
            <xsl:apply-templates select="./*[@conceptId]" mode="addElementForConcept">
                <xsl:with-param name="datasetName" select="$datasetName"/>
            </xsl:apply-templates>
        </QuestionnaireResponse>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates a table row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match=".[@conceptId]" mode="addElementForConcept">
        <xsl:param name="datasetName"/>
            <item>
                <linkId value="{concat('peri32-dataelement-',@conceptId)}"/> 
                <text value="{name()}"/>
                <xsl:if test="@value">
                <answer>
                    <xsl:choose>
                        <xsl:when test="@datatype='datetime'">
                            <valueDateTime value="{@value}">
                                <xsl:attribute name="value">
                                    <xsl:call-template name="format2FHIRDate">
                                        <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                                        <xsl:with-param name="precision" select="'DAY'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </valueDateTime>
                        </xsl:when>
                        <xsl:when test="not(@code) and (@value castable as xs:integer or @value castable as xs:decimal)">
                            <xsl:element name="valueQuantity" namespace="http://hl7.org/fhir">
                                <xsl:call-template name="hoeveelheid-to-Quantity">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="any-to-value"> 
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="elemName">value</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </answer>
                </xsl:if>
            <xsl:apply-templates select="./*[@conceptId]" mode="addElementForConcept">
                <xsl:with-param name="datasetName" select="$datasetName"/>
            </xsl:apply-templates>
            </item>
        <!--</xsl:if>-->
    </xsl:template>
    
    
    
    <xsl:template match="node()|@*"/>
    
</xsl:stylesheet>