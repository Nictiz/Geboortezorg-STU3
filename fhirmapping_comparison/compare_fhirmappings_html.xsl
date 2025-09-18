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
        <!-- 1) Collect all differences into a temp tree -->
        <xsl:variable name="diffs" as="element(diffs)">
            <diffs xmlns="">
                <xsl:for-each select="record">
                    <xsl:variable name="id" select="normalize-space(ID)"/>
                    <xsl:variable name="others" select="key('rec-by-id', $id, $other)"/>
                    
                    <xsl:choose>
                        <!-- (a) Missing in second -->
                        <xsl:when test="empty($others)">
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
                        
                        <!-- (b) Multiples in second -->
                        <xsl:when test="count($others) gt 1">
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
                        
                        <!-- (c) Exactly one match -->
                        <xsl:when test="count($others) = 1">
                            <xsl:variable name="o" select="$others[1]"/>
                            
                            <xsl:variable name="m1" select="f:canon(mapping)"/>
                            <xsl:variable name="p1" select="f:canon(profile)"/>
                            <xsl:variable name="m2" select="f:canon($o/mapping)"/>
                            <xsl:variable name="p2" select="f:canon($o/profile)"/>
                            
                            <xsl:if test="not(($m1=$m2) and ($p1=$p2))">
                                <xsl:choose>
                                    <!-- mapping added if both are nvt/ntb or empty -->
                                    <xsl:when test="($m1=('nvt','ntb')) and ($p1=('nvt','ntb')) 
                                        or (normalize-space($m1)='' and normalize-space($p1)='')">
                                        <difference type="mapping-added">
                                            <element>
                                                <ID><xsl:value-of select="$id"/></ID>
                                                <naam><xsl:value-of select="naam"/></naam>
                                            </element>
                                            <original_mapping>
                                                <profile><xsl:value-of select="profile"/></profile>
                                                <mapping><xsl:value-of select="mapping"/></mapping>
                                            </original_mapping>
                                            <other_mapping>
                                                <profile status="{if ($p1=$p2) then 'identical' else 'changed'}">
                                                    <xsl:value-of select="if ($p1=$p2) then $p1 else normalize-space($o/profile)"/>
                                                </profile>
                                                <mapping status="{if ($m1=$m2) then 'identical' else 'changed'}">
                                                    <xsl:value-of select="if ($m1=$m2) then $m1 else normalize-space($o/mapping)"/>
                                                </mapping>
                                            </other_mapping>
                                        </difference>
                                    </xsl:when>
                                    
                                    <!-- default: changed -->
                                    <xsl:otherwise>
                                        <difference type="changed">
                                            <element>
                                                <ID><xsl:value-of select="$id"/></ID>
                                                <naam><xsl:value-of select="naam"/></naam>
                                            </element>
                                            <original_mapping>
                                                <profile><xsl:value-of select="profile"/></profile>
                                                <mapping><xsl:value-of select="mapping"/></mapping>
                                            </original_mapping>
                                            <other_mapping>
                                                <profile status="{if ($p1=$p2) then 'identical' else 'changed'}">
                                                    <xsl:value-of select="if ($p1=$p2) then $p1 else normalize-space($o/profile)"/>
                                                </profile>
                                                <mapping status="{if ($m1=$m2) then 'identical' else 'changed'}">
                                                    <xsl:value-of select="if ($m1=$m2) then $m1 else normalize-space($o/mapping)"/>
                                                </mapping>
                                            </other_mapping>
                                        </difference>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </diffs>
        </xsl:variable>
        
        <!-- 2) Render HTML report -->
        <xsl:result-document href="comparison_output_all.html" method="html" indent="yes">
            <html>
                <head>
                    <meta charset="utf-8"/>
                    <title>FHIR Mapping Comparison</title>
                    <style>
                        body{font-family:system-ui,Segoe UI,Arial,sans-serif;margin:24px}
                        h1{margin:0 0 8px}
                        .summary{margin:8px 0 20px;color:#555}
                        .toc a{margin-right:12px}
                        table{border-collapse:collapse;width:100%;margin:16px 0}
                        th,td{border:1px solid #ddd;padding:8px;vertical-align:top}
                        th{background:#f5f5f5;position:sticky;top:0}
                        tr:nth-child(even){background:#fafafa}
                        .badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:12px;background:#eee}
                        /* explicit status badges */
                        .badge.changed{background:#ffe066;}
                        .badge.identical{background:#bdf0bd;}
                        /* --- Count badges (for group summaries and headers) --- */
                        .count-badge {
                        display:inline-block;
                        padding:2px 8px;
                        border-radius:12px;
                        font-size:12px;
                        background:#eee;
                        }
                        section.changed .count-badge        { background:#ffe066; }
                        section.mapping-added .count-badge  { background:#d6f5d6; }
                        section.missing-in-other .count-badge { background:#ffd6d6; }
                        section.multiples-in-other .count-badge { background:#e6e6ff; }
                        .mono{font-family:ui-monospace,Consolas,monospace}
                    </style>
                </head>
                <body>
                    <h1>FHIR Mapping Comparison</h1>
                    <div class="summary">
                        Total differences:
                        <strong><xsl:value-of select="count($diffs/difference)"/></strong>
                        —
                        <xsl:for-each-group select="$diffs/difference" group-by="@type">
                            <xsl:sort select="current-grouping-key()"/>
                            <span class="badge">
                                <xsl:value-of select="current-grouping-key()"/>:
                                <xsl:value-of select="count(current-group())"/>
                            </span>
                        </xsl:for-each-group>
                    </div>
                    
                    <div class="explanation">
                        <p><strong>Original</strong> refers to the fhirmapping-3-2 file at the time of the release of Simplifier package 1.3.2.</p>
                        <p><strong>Other</strong> refers to the fhirmapping file that we want to compare to, in this case the fhirmapping-3-2 file at the time of the release of package 3.0.0.</p>
                    </div>
                    
                    <p>Quick links:</p>
                    <div class="toc">
                        <xsl:for-each-group select="$diffs/difference" group-by="@type">
                            <xsl:sort select="if (current-grouping-key()='changed') then 0 else 1"/>
                            <a href="#{current-grouping-key()}"><xsl:value-of select="current-grouping-key()"/></a>
                        </xsl:for-each-group>
                    </div>
                    
                    <xsl:for-each-group select="$diffs/difference" group-by="@type">
                        <xsl:sort select="if (current-grouping-key()='changed') then 0 else 1"/>
                        <section id="{current-grouping-key()}" class="{current-grouping-key()}">
                            <h2>
                                <xsl:value-of select="current-grouping-key()"/>
                                <span class="badge"><xsl:value-of select="count(current-group())"/></span>
                            </h2>
                            <table>
                                <thead>
                                    <tr>
                                        <th style="width:22%">ID</th>
                                        <th style="width:28%">Naam</th>
                                        <th style="width:25%">Original (profile · mapping)</th>
                                        <th style="width:25%">Other (profile · mapping)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="current-group()">
                                        <xsl:sort select="element/naam"/>
                                        <xsl:sort select="element/ID"/>
                                        <tr>
                                            <td class="mono"><xsl:value-of select="element/ID"/></td>
                                            <td><xsl:value-of select="element/naam"/></td>
                                            <td>
                                                <div><strong>profile:</strong> <xsl:value-of select="original_mapping/profile"/></div>
                                                <div><strong>mapping:</strong> <xsl:value-of select="original_mapping/mapping"/></div>
                                            </td>
                                            <td>
                                                <div>
                                                    <strong>profile:</strong>
                                                    <xsl:variable name="ps" select="other_mapping/profile/@status"/>
                                                    <span>
                                                        <xsl:value-of select="other_mapping/profile"/>
                                                        <xsl:if test="$ps">
                                                            <span class="badge { $ps }"><xsl:value-of select="$ps"/></span>
                                                        </xsl:if>
                                                    </span>
                                                </div>
                                                <div>
                                                    <strong>mapping:</strong>
                                                    <xsl:variable name="ms" select="other_mapping/mapping/@status"/>
                                                    <span>
                                                        <xsl:value-of select="other_mapping/mapping"/>
                                                        <xsl:if test="$ms">
                                                            <span class="badge { $ms }"><xsl:value-of select="$ms"/></span>
                                                        </xsl:if>
                                                    </span>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </section>
                    </xsl:for-each-group>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    

</xsl:stylesheet>
