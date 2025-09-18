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

<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:fhir="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:func" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
    version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>Compares two fhir mapping files 
            <xd:p>Takes one file as a 'reference', and checks
                the dataset.record.ID elements one by one against the equivalent elements of the
                other file</xd:p>
        </xd:desc>
    </xd:doc>


    <!--chatgpt generated:-->

    <xsl:output method="xml" indent="yes"/>
    <!-- Pass the path/URI to the second input file -->

    <xsl:param name="other-uri" as="xs:string" select="'fhirmapping-3-2_package3.0.0.xml'"/>

    <!-- Load the second document -->
    <xsl:variable name="other" select="doc($other-uri)"/>

    <!-- Key on the OTHER doc by normalized ID -->
    <xsl:key name="rec-by-id" match="/dataset/record" use="normalize-space(ID)"/>

    <!-- Canonicalize (trim + lowercase) -->
    <xsl:function name="f:canon" as="xs:string">
        <xsl:param name="n" as="node()?"/>
        <xsl:sequence select="lower-case(normalize-space(string($n)))"/>
    </xsl:function>

    <!-- Root: primary input is the first file -->
    <xsl:template match="/dataset">
        <xsl:result-document href="comparison_output_all.xml" method="xml" indent="yes">

            <fhirmapping_differences>
            <xsl:for-each select="record">
                <xsl:variable name="id" select="normalize-space(ID)"/>
                <xsl:variable name="others" select="key('rec-by-id', $id, $other)"/>

                <xsl:choose>
                    <xsl:when test="empty($others)"> <!--(a) Mapping missing (not found) in second file-->
                        <difference type="missing-in-other">
                            <element>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="naam"/></naam>
                            </element>
                            <original_mapping>
                                <profile><xsl:value-of select="profile"/></profile>
                                <mapping><xsl:value-of select="mapping"/></mapping>
                            </original_mapping>
                        </difference>
                    </xsl:when>
                    <xsl:when test="count($others) gt 1"> <!--(b) Found multiple mappings in second file-->
                        <difference type="multiples-in-other">
                            <element>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="naam"/></naam>
                            </element>
                            <original_mapping>
                                <profile><xsl:value-of select="profile"/></profile>
                                <mapping><xsl:value-of select="mapping"/></mapping>
                            </original_mapping>
                            <xsl:for-each select="$others">
                                <other_mapping>
                                    <profile><xsl:value-of select="profile"/></profile>
                                    <mapping><xsl:value-of select="mapping"/></mapping>
                                </other_mapping>
                            </xsl:for-each>
                        </difference>
                    </xsl:when>
                    <xsl:when test="count($others) = 1"> <!--(c) Exactly one match: compare mapping/profile-->
                        <xsl:variable name="o" select="$others[1]"/>

                        <xsl:variable name="m1" select="f:canon(mapping)"/>
                        <xsl:variable name="p1" select="f:canon(profile)"/>
                        <xsl:variable name="m2" select="f:canon($o/mapping)"/>
                        <xsl:variable name="p2" select="f:canon($o/profile)"/>

                        <!-- Only report differences beyond case/whitespace -->
                        <xsl:if test="not(($m1=$m2)and($p1=$p2))"> <!--found at least one change in profile or mapping-->
                            <xsl:choose>
                                <xsl:when test="($m1='nvt' or $m1='ntb') and ($p1='nvt' or $p1='ntb')">
                                    <difference type="mapping-added">
                                        <element>
                                            <ID><xsl:value-of select="$id"/></ID>
                                            <naam><xsl:value-of select="naam"/></naam>
                                        </element>
                                        <original_mapping>
                                            <profile><xsl:value-of select="profile"/></profile>
                                            <mapping><xsl:value-of select="mapping"/></mapping></original_mapping>
                                        <other_mapping>
                                            <xsl:if test="$p1 = $p2">
                                                <profile status="identical"><xsl:value-of select="normalize-space($p1)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$p1 != $p2">
                                                <profile><xsl:value-of select="normalize-space($o/profile)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$m1 = $m2">
                                                <mapping status="identical"><xsl:value-of select="normalize-space($m1)"/></mapping>
                                            </xsl:if>
                                            <xsl:if test="$m1 != $m2">
                                                <mapping><xsl:value-of select="normalize-space($o/mapping)"/></mapping>
                                            </xsl:if>
                                        </other_mapping>
                                    </difference>
                                </xsl:when>
                                <xsl:when test="normalize-space($m1)='' and normalize-space($p1)=''">
                                    <difference type="mapping-added">
                                        <element>
                                            <ID><xsl:value-of select="$id"/></ID>
                                            <naam><xsl:value-of select="naam"/></naam>
                                        </element>
                                        <original_mapping>
                                            <profile><xsl:value-of select="profile"/></profile>
                                            <mapping><xsl:value-of select="mapping"/></mapping></original_mapping>
                                        <other_mapping>
                                            <xsl:if test="$p1 = $p2">
                                                <profile status="identical"><xsl:value-of select="normalize-space($p1)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$p1 != $p2">
                                                <profile><xsl:value-of select="normalize-space($o/profile)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$m1 = $m2">
                                                <mapping status="identical"><xsl:value-of select="normalize-space($m1)"/></mapping>
                                            </xsl:if>
                                            <xsl:if test="$m1 != $m2">
                                                <mapping><xsl:value-of select="normalize-space($o/mapping)"/></mapping>
                                            </xsl:if>
                                        </other_mapping>
                                    </difference>
                                </xsl:when>
                                <xsl:otherwise>
                                    <difference type="changed">
                                        <element>
                                            <ID><xsl:value-of select="$id"/></ID>
                                            <naam><xsl:value-of select="naam"/></naam>
                                        </element>
                                        <original_mapping>
                                            <profile><xsl:value-of select="profile"/></profile>
                                            <mapping><xsl:value-of select="mapping"/></mapping></original_mapping>
                                        <other_mapping>
                                            <xsl:if test="$p1 = $p2">
                                                <profile status="identical"><xsl:value-of select="normalize-space($p1)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$p1 != $p2">
                                                <profile><xsl:value-of select="normalize-space($o/profile)"/></profile>
                                            </xsl:if>
                                            <xsl:if test="$m1 = $m2">
                                                <mapping status="identical"><xsl:value-of select="normalize-space($m1)"/></mapping>
                                            </xsl:if>
                                            <xsl:if test="$m1 != $m2">
                                                <mapping><xsl:value-of select="normalize-space($o/mapping)"/></mapping>
                                            </xsl:if>
                                        </other_mapping>
                                    </difference>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            
                        </xsl:if>
                    </xsl:when>

                </xsl:choose>

            </xsl:for-each>
        </fhirmapping_differences>
        </xsl:result-document>  
    </xsl:template>

</xsl:stylesheet>
