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
        <xd:desc>Produces a FHIR custom resource based on the ADA dataset structure
            <xd:p><xd:b>Expected input</xd:b>DECOR release file containing ADA community info that holds relevant mapping information. Use tool "adarelease_2_adacommunity.xsl" (should be where you found this tool) to set set up the initial community for upload on ART-DECOR</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2023-03-31 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match="dataset">
        <xsl:variable name="dataset" select="."/>
        <xsl:variable name="datasetName" select="translate(translate(./name,' ',''),'.','')"/>
        <xsl:variable name="transactionId" select="@transactionId"/>
        <StructureDefinition>    
            <id value="{$datasetName}"/>
            <url value="{concat('http://nictiz/fhir/StructureDefinition/dataset/',$datasetName)}"/>
            <name value="{$datasetName}"/>
            <status value="draft"/>
            <fhirVersion value="3.0.2"/>
            <abstract value="false"/>
            <kind value="resource"/>
            <type value="{$datasetName}"/>
            <baseDefinition value="http://hl7.org/fhir/StructureDefinition/DomainResource"/>
            <derivation value="constraint"/>
            <differential>
                <element>
                    <id value="{$datasetName}"/>
                    <path value="{$datasetName}"/>        
                </element>
                <xsl:apply-templates select="concept" mode="addElementForConcept">
                    <xsl:with-param name="datasetName" select="$datasetName"/>
                    <xsl:with-param name="transactionId" select="$transactionId"/>
                </xsl:apply-templates>
            </differential>
        </StructureDefinition>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates a table row for a concept</xd:desc>
    </xd:doc>
    <xsl:template match="concept" mode="addElementForConcept">
        <xsl:param name="datasetName"/>
        <xsl:param name="transactionId"/>
        <xsl:variable name="path">
            <xsl:value-of select="ancestor::concept/@shortName" separator="."/>
        </xsl:variable>
        <xsl:variable name="fullPath">
            <xsl:choose>
                <xsl:when test="$path=''">
                    <xsl:value-of select="concat($datasetName,'.',@shortName)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($datasetName,'.',$path,'.',@shortName)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
<!--        <xsl:if test="starts-with($fullPath,'DatasetGeboortezorg32.administratief')">-->
            <element>
                <id value="{$fullPath}"/>
                <path value="{$fullPath}"/>
                <xsl:choose>
                    <xsl:when test="$transactionId">
                        <min value="{@minimumMultiplicity}"/>
                        <max value="{@maximumMultiplicity}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <min value="0"/>
                        <max value="*"/> 
                    </xsl:otherwise>
                </xsl:choose>
                <type>
                    <code value="BackBoneElement"/>
                    <!--<code><xsl:value-of select="$fhir-datatype"/></code>-->
                    <!--<profile><xsl:value-of select="$fhir-datatype-profile"/></profile>-->
                </type>              
            </element>
            <xsl:if test="not(./concept)">
                <xsl:apply-templates select="." mode="addElementForAttribute">
                    <xsl:with-param name="datasetName" select="$datasetName"/>
                    <xsl:with-param name="transactionId" select="$transactionId"/>
                    <xsl:with-param name="fullPath" select="$fullPath"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:apply-templates select="./concept" mode="addElementForConcept">
                <xsl:with-param name="datasetName" select="$datasetName"/>
                <xsl:with-param name="transactionId" select="$transactionId"/>
            </xsl:apply-templates>
        <!--</xsl:if>-->
    </xsl:template>
    
    <xsl:template match="concept" mode="addElementForAttribute">
        <xsl:param name="datasetName"/>
        <xsl:param name="transactionId"/>
        <xsl:param name="fullPath"/>
        <xsl:variable name="ada-datatype">
            <xsl:value-of select="valueDomain/@type"/>
        </xsl:variable>
        <xsl:variable name="fhir-datatype">
            <xsl:choose>
                <xsl:when test="$ada-datatype=''">BackBoneElement</xsl:when>
                <xsl:when test="$ada-datatype='code'">code</xsl:when>
                <xsl:when test="$ada-datatype='identifier'">Identifier</xsl:when>
                <xsl:when test="$ada-datatype='decimal'">decimal</xsl:when>
                <xsl:when test="$ada-datatype=('complex','integer', 'count')">integer</xsl:when>
                <xsl:when test="$ada-datatype=('quantity', 'duration', 'currency')">Quantity</xsl:when>
                <xsl:when test="$ada-datatype='boolean'">boolean</xsl:when>
                <xsl:when test="$ada-datatype='date'">date</xsl:when>
                <xsl:when test="$ada-datatype='datetime'">datetime</xsl:when>
                <xsl:when test="$ada-datatype='blob'">base64Binary</xsl:when>
                <xsl:when test="$ada-datatype=('string', 'text')">string</xsl:when>
                <xsl:otherwise>UNKNOWN DATATYPE</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
<!--        <xsl:if test="starts-with($fullPath,'administratief')">-->
            <element>
                <id value="{concat($fullPath,'._value')}"/>
                <path value="{concat($fullPath,'._value')}"/>
                <min value="0"/>
                <max value="1"/> 
                <type>
                    <code><xsl:value-of select="$fhir-datatype"/></code>
                    <!--<profile><xsl:value-of select="$fhir-datatype-profile"/></profile>-->
                </type>              
            </element>
            <element>
                <id value="{concat($fullPath,'._code')}"/>
                <path value="{concat($fullPath,'._code')}"/>
                <min value="0"/>
                <max value="1"/> 
                <type>
                    <code><xsl:value-of select="'code'"/></code>
                    <!--<profile><xsl:value-of select="$fhir-datatype-profile"/></profile>-->
                </type>                
            </element>
            <element>
                <id value="{concat($fullPath,'._codeSystem')}"/>
                <path value="{concat($fullPath,'._codeSystem')}"/>
                <min value="0"/>
                <max value="1"/> 
                <type>
                    <code><xsl:value-of select="'string'"/></code>
                    <!--<profile><xsl:value-of select="$fhir-datatype-profile"/></profile>-->
                </type>             
            </element>
            <element>
                <id value="{concat($fullPath,'._displayName')}"/>
                <path value="{concat($fullPath,'._displayName')}"/>
                <min value="0"/>
                <max value="1"/> 
                <type>
                    <code><xsl:value-of select="'string'"/></code>
                    <!--<profile><xsl:value-of select="$fhir-datatype-profile"/></profile>-->
                </type>             
            </element>
        <!--</xsl:if>-->
        <!-- todo: oplossing voor referentiewaarden -->
    </xsl:template>
    
    <xsl:template match="node()|@*"/>
    
</xsl:stylesheet>