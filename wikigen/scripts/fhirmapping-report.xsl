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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nf="http://www.nictiz.nl/functions" exclude-result-prefixes="#all" version="3.0">
        
    <xd:doc scope="stylesheet">
        <xd:desc>Produces mappping report html from FHIR mapping that tells you about thing relevant for QA
            <xd:p><xd:b>Expected input</xd:b> fhirmapping(-3-2).xml</xd:p>
            <xd:p><xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2025-08-19 version 0.2 AH</xd:li>
                    <xd:li>2020-12-02 version 0.1 LM</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="../../../YATC-internal/ada-2-fhir/env/fhir/2_fhir_fhir_include.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="outputdir" select="'.'"/>
    
    <xsl:variable name="fhirVersion" select="'3.0'"/>
    <xsl:variable name="all-profiles" select="collection('../../profiles/?select=*.xml&amp;recurse=yes')//f:StructureDefinition" as="element(f:StructureDefinition)+"/>
    <xsl:variable name="fhirmapping-file" select="doc('../../fhirmapping-3-2.xml')/*" as="element()+"/>
    <xsl:variable name="ada-release-file" select="doc('../../../art_decor/projects/perinatologie-326/definitions/perinatologie-326-ada-release.xml')/*" as="element()"/>
    
    <xsl:variable name="allValueSets" select="collection('../../profiles/ValueSets?select=*.xml&amp;recurse=yes')//f:ValueSet"/>
    <xsl:variable name="valueSets" as="element(f:ValueSet)*">
        <xsl:for-each select="$allValueSets[starts-with(f:name/@value, 'bc-')]">
            <xsl:choose>
                <xsl:when test="descendant::f:valueSet">
                    <xsl:copy>
                        <xsl:copy-of select="* except f:compose"/>
                        <xsl:for-each select="f:compose">
                            <xsl:copy>
                                <xsl:copy-of select="f:lockedDate | f:inactive"/>
                                <xsl:for-each select="f:include">
                                    <xsl:copy>
                                        <xsl:copy-of select="* except f:valueSet"/>
                                        <xsl:for-each select="f:valueSet">
                                            <xsl:copy>
                                                <xsl:copy-of select="@*"/>
                                                <xsl:copy-of select="$allValueSets[f:url/@value = current()/@value]"/>
                                            </xsl:copy>
                                        </xsl:for-each>
                                    </xsl:copy>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    
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
        <xsl:variable name="rows" as="element(tr)*">
            <xsl:for-each-group select="$fhirmapping-file/record" group-by="ID">
                <xsl:variable name="mappingRecord" select="current-group()"/>
                <xsl:variable name="datasetConcept" select="nf:getDataConcept(current-grouping-key())" as="element(concept)*"/>
                <xsl:variable name="profileMapping" select="$all-profiles//f:mapping[f:map/@value = current-grouping-key()]" as="element(f:mapping)*"/>
                <!-- Deactivated ... too simplistic -->
                <xsl:variable name="terminologyAssociationConcept" select="$datasetConcept[1]/terminologyAssociationssss"/>
                <!--<xsl:variable name="terminologyAssociationConcept" select="$datasetConcept[1]/terminologyAssociation[@conceptId = ../@id]"/>-->
              
                <xsl:variable name="columns" as="element()*">
                    <xsl:if test="$datasetConcept">
                        <td>
                            <xsl:value-of select="current-grouping-key()"/>
                        </td>
                        <td>
                            <xsl:for-each select="distinct-values(naam)">
                                <div>
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="string-join($datasetConcept[1]/ancestor-or-self::concept/name[1], '/')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </div>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:for-each select="mapping">
                                <div>
                                    <xsl:value-of select="."/>
                                </div>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:for-each select="profile">
                                <div>
                                    <xsl:value-of select="."/>
                                </div>
                            </xsl:for-each>
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
                                    <span style="color: red; font-weight: bold;" class="transaction-mismatch">WARNING No transactions</span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$profileMapping">
                                    <ul>
                                        <xsl:for-each select="$profileMapping">
                                            <xsl:variable name="profileName" select="ancestor-or-self::f:StructureDefinition/f:name/@value"/>
                                            <xsl:variable name="elementId" select="ancestor-or-self::f:element/@id"/>
                                            <xsl:variable name="profileMismatch" select="empty($mappingRecord[profile = $profileName])"/>
                                            <xsl:variable name="pathMismatch" select="empty($mappingRecord[mapping = $elementId])"/>
                                            <!-- Assumption ... checking code is enough, codeSystem (OID vs URI) complexity not necessary -->
                                            <!-- <concept><code value="249163006"/><display value="begin van persen tijdens partus (waarneembare entiteit)"/></concept> -->
                                            <xsl:variable name="terminologyMismatch" as="xs:boolean?">
                                                <xsl:if test="$terminologyAssociationConcept and not(contains($elementId, '.'))">
                                                    <xsl:for-each select="$valueSets[f:name/@value = concat($profileName, '-code')][empty(f:compose/f:include/f:valueSet[not(f:ValueSet)])]">
                                                        <xsl:value-of select="empty(.//f:concept[f:code/@value = $terminologyAssociationConcept/@code])"/>
                                                    </xsl:for-each>
                                                </xsl:if>
                                            </xsl:variable>
                                            
                                            <li>
                                                <xsl:if test="$profileMismatch or $pathMismatch">
                                                    <span style="color: red; font-weight: bold;" class="profile-mismatch">
                                                        <xsl:text>WARNING </xsl:text>
                                                    </span>
                                                </xsl:if>
                                                <xsl:text>Mapping </xsl:text>
                                                <span>
                                                    <xsl:if test="$profileMismatch">
                                                        <xsl:attribute name="style" select="'color: red; font-weight: bold;'"/>
                                                        <xsl:attribute name="class" select="'profile-mismatch'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="ancestor-or-self::f:StructureDefinition/f:name/@value"/>
                                                </span>
                                                <xsl:text> - path </xsl:text>
                                                <span>
                                                    <xsl:if test="$pathMismatch">
                                                        <xsl:attribute name="style" select="'color: red; font-weight: bold;'"/>
                                                        <xsl:attribute name="class" select="'profile-mismatch'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="ancestor-or-self::f:element/@id"/>
                                                </span>
                                                <xsl:if test="$terminologyMismatch">
                                                    <div style="color: red; font-weight: bold;" class="terminology-mismatch">
                                                        <xsl:text>Terminology mismatch. Dataset: "</xsl:text>
                                                        <xsl:value-of select="string-join($terminologyAssociationConcept/concat(@code, ' (', local:getUri(@codeSystem), ')'), ', ')"/>
                                                        <xsl:text>" not present in value set </xsl:text>
                                                        <xsl:value-of select="concat($profileName, '-code')"/>
                                                        <xsl:for-each select="$valueSets[ends-with(f:name/@value, '-code')][descendant::f:concept[f:code/@value = $terminologyAssociationConcept/@code]]/f:name/@value">
                                                            <div><xsl:text>Found code in ValueSet </xsl:text><xsl:value-of select="."/></div>
                                                        </xsl:for-each>
                                                    </div>
                                                </xsl:if>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:when>
                                <xsl:when test="starts-with(profile, 'bc-')">
                                    <span style="color: red; font-weight: bold;" class="profile-mismatch">WARNING No mappings</span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span style="font-style: italic;">No mappings</span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:variable name="transactionIssue" as="xs:boolean" select="$columns//@class = 'transaction-mismatch'"/>
                <xsl:variable name="profileIssue" as="xs:boolean"  select="$columns//@class = 'profile-mismatch'"/>
                <xsl:variable name="terminologyIssue" as="xs:boolean"  select="$columns//@class = 'terminology-mismatch'"/>
                
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
                
                <xsl:if test="$columns">
                    <tr>
                        <xsl:if test="not($profileIssue or $terminologyIssue)">
                            <xsl:attribute name="class">row-valid</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$transactionIssue">
                            <xsl:attribute name="aria-transaction-issue">true</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$profileIssue">
                            <xsl:attribute name="aria-profile-issue">true</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$terminologyIssue">
                            <xsl:attribute name="aria-terminology-issue">true</xsl:attribute>
                        </xsl:if>

                        <xsl:copy-of select="$columns"/>
                    </tr>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        
        <!-- Generate out in html table using fhirmapping as entry point for checking profiles against -->
        <xsl:message>Creating <xsl:value-of select="$outputdir"/>/fhirmapping-report.html ...</xsl:message>
        <xsl:variable name="profileIssueCount" select="count($rows[@aria-profile-issue])"/>
        <xsl:variable name="transactionIssueCount" select="count($rows[@aria-transaction-issue])"/>
        <xsl:result-document href="{$outputdir}/fhirmapping-report.html">
            <html>
                <head>
                    <title>Mapping report</title>
                    <meta charset="UTF-8">&#160;</meta>
                    <style>
                        * { font-family: Verdana, sans-serif; } 
                        tr:nth-child(even) { background-color: lightgrey; } 
                        .profile-mismatch, 
                        .transaction-mismatch { color: red; font-weight: bold; }
                    </style>
                    <script type="text/javascript" src="https://decor.nictiz.nl/ada/resources/scripts/ada.js">&#160;</script>
                </head>
                <body>
                    <h3>Mapping report</h3>
                    <div>Generated: <xsl:value-of select="current-dateTime()"/></div>
                    <div>Mappings in fhirmapping-3-2.xml: total=<xsl:value-of select="count($fhirmapping-file/record)"/>, present in transaction=<b><xsl:value-of select="count($rows)"/></b> (table only lists mappings related to PWD 3.2 transactions)</div>
                    <div>Mappings in profiles/extensions: <xsl:value-of select="count($all-profiles//f:mapping[f:identity/@value = 'gebz-peri-v3.2'])"/></div>
                    <div>
                        <input id="hide-valid" type="checkbox" name="hide-valid" style="margin-left: 1em;" onchange="showHideRows()">
                            <xsl:text>Hide valid</xsl:text>
                        </input>
                        - valid: <b><xsl:value-of select="count($rows[@class = 'row-valid'])"/></b>
                        - with transaction issue: <span style="font-weight: bold; color:{if ($profileIssueCount gt 0) then 'red;' else 'green'};"><xsl:value-of select="$profileIssueCount"/></span>
                        - with profile issue: <span style="font-weight: bold; color:{if ($transactionIssueCount gt 0) then 'red;' else 'green'};"><xsl:value-of select="$transactionIssueCount"/></span>
                        <!--- with terminology issue: <xsl:value-of select="count($rows[@aria-terminology-issue])"/>-->
                    </div>
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
                        <xsl:copy-of select="$rows"/> 
                    </table>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:function name="nf:getDataConcept" as="element(concept)?">
        <xsl:param name="conceptId"/>
        
        <xsl:variable name="theConcept" select="($ada-release-file//concept[@id = $conceptId or @iddisplay = $conceptId])[1]"/>
        <xsl:choose>
            <xsl:when test="$theConcept[contains]">
                <xsl:sequence select="nf:getDataConcept($theConcept/contains/@ref)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$theConcept"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>