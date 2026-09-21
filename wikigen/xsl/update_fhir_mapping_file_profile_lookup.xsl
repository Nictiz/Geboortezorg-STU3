<?xml version="1.0" encoding="UTF-8"?>
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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"  xmlns:f="http://hl7.org/fhir" exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Updates the existing fhir mapping xml file (fhirmapping-3-2.xml) for a new version of the ART-DECOR dataset xml. 
            The stylesheet will copy all concepts from the dataset xml, compare the mapping information found in the bc-profiles to the mapping information found in the existing version of fhirmapping-3-2.xml, and fill the record elements accordingly. 
            The stylesheet also produces additional information files in the qa folder. 
            The xml file compiled-profile-mappings.xml holds all mapping information found in the bc-profiles, and the log-messages-mapping.txt holds information about the comparison of the mapping information found for each dataset concept. 
            <xd:p><xd:b>Expected input: </xd:b>DECOR dataset xml file.</xd:p>
            <xd:p><xd:b>Expected output: </xd:b>An updated version of the existing fhirmapping information.</xd:p>
            <xd:p><xd:b>History: </xd:b>
                <xd:ul>
                    <xd:li>2025-11-05 version 0.1 VG</xd:li>
                </xd:ul>
            </xd:p>
                <xd:p><xd:b>Based on: </xd:b>the existing update_fhir_mapping_file.xsl, version 0.1 (2021-08-24, LM)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="debug" as="xs:boolean" select="true()"/> <!--TOGGLE BETWEEN true()/false() TO SEE MESSAGE LOGGING-->
    <xsl:param name="compiled-mappings-output" as="xs:string" select="'qa/compiled-profile-mappings.xml'"/>
    <xsl:param name="log-messages-output" as="xs:string" select="'qa/log-messages-mapping.txt'"/>
    
    <!-- Point to the 'profiles' folder that contains all bc- profile xml's -->
    <xsl:param name="bc-profile-folder" as="xs:string" select="'../../profiles/'"/>
    <!-- Make it an absolute directory URI, relative to the stylesheet location -->
    <xsl:variable name="bc-profile-folder-uri" as="xs:anyURI" select="resolve-uri($bc-profile-folder, static-base-uri())"/>
    <!-- Load only files matching bc-*.xml in that folder (no subfolders) -->
    <xsl:variable name="bc-profile-files" select="collection(concat($bc-profile-folder-uri,'?select=bc-*.xml;recurse=no;on-error=warning'))"/>
    <xsl:variable name="fhirmapping-file" select="document('../../fhirmapping-3-2.xml')"/>
    
    <xsl:key name="fhirmapping-lookup" match="dataset/record" use="ID"/>
    <xsl:key name="dataset-lookup" match="//concept" use="@iddisplay/string()"/>

    <xd:doc>
        <xd:desc>Make base table</xd:desc>
    </xd:doc>
    <xsl:template match="dataset">        
        <!-- Compile all <mapping> entries found in bc- profiles (under all differential.element) into an in-memory doc -->
        <xsl:variable name="compiled-mappings" as="document-node()">
            <xsl:document>
                <dataset>
                    <xsl:for-each select="$bc-profile-files">
                        <!-- record.profile from /name/@value -->
                        <xsl:variable name="profile-bc" select="normalize-space(/*/f:name/@value)"/>  
                        <!-- each element that has a mapping -->
                        <xsl:for-each select="/*/f:differential/f:element[f:mapping]">
                            <!-- record.mapping from element/@id -->
                            <xsl:variable name="mapping-bc" select="normalize-space(@id)"/> <!--changed from f:path/@value to @id-->
                            <!-- each mapping under the element -->
                            <xsl:for-each select="f:mapping">
                                <!-- record.ID from mapping/map/@value -->
                                <xsl:variable name="id-bc"   select="normalize-space(f:map/@value)"/>
                                <!-- record.naam from mapping/comment/@value -->
                                <xsl:variable name="naam-bc" select="normalize-space(f:comment/@value)"/>
                                <record>
                                    <ID><xsl:value-of select="$id-bc"/></ID> <!-- record.ID from mapping/map/@value -->
                                    <naam><xsl:value-of select="$naam-bc"/></naam> <!-- record.naam from mapping/comment/@value -->
                                    <mapping><xsl:value-of select="$mapping-bc"/></mapping>
                                    <profile><xsl:value-of select="$profile-bc"/></profile>                                                                 
                                </record>  
                                <xsl:if test="$debug">
                                    <xsl:message
                                        select="concat('expected record → ID=', $id-bc,
                                        ' | naam=', $naam-bc,
                                        ' | mapping=', $mapping-bc,
                                        ' | profile=', $profile-bc)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </dataset>
            </xsl:document>
        </xsl:variable>
        <!--write the compiled mappings to a document in the qa folder-->
        <xsl:result-document href="{resolve-uri($compiled-mappings-output, static-base-uri())}" method="xml" indent="yes" encoding="UTF-8">
            <xsl:sequence select="$compiled-mappings/node()"/>
        </xsl:result-document>
        
        <!--debug messages, may be removed-->
        <xsl:message select="concat('bc-profile files found: ', count($bc-profile-files))"/>
        <xsl:message select="concat('Wrote ', count($compiled-mappings//record),' mappings found in bc-profiles to ', resolve-uri($compiled-mappings-output, static-base-uri()))"/>

        <!--write log messages to a document in the qa folder-->
        <xsl:variable name="dataset" select="."/>
        <xsl:result-document href="{resolve-uri($log-messages-output, static-base-uri())}" method="text" encoding="UTF-8">
            <xsl:for-each select="$dataset//concept[@type=('group','item') and @statusCode!='cancelled' and not((.|ancestor::concept)[lower-case(normalize-space(string(name[@language='nl-NL'])))='prullenbak'])]">
                <xsl:variable name="line">
                    <xsl:apply-templates select="." mode="createLogLine">
                        <xsl:with-param name="compiled-mappings" select="$compiled-mappings"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:value-of select="normalize-space($line)"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>

        <!--loop over all active dataset concepts excluding the prullenbak concepts, in order to create <record> elements in the output-->
        <xsl:processing-instruction name="xml-model" select="'href=&quot;qa/fhirmapping.sch&quot; type=&quot;application/xml&quot; schematypens=&quot;http://purl.oclc.org/dsdl/schematron&quot;'" />
        <dataset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:copy-of select="@*"/>
            <!--loop over all <concept> elements in your source (i.e. the dataset) xml, and create a record-->
            <xsl:for-each select="$dataset//concept[@type=('group','item') and @statusCode!='cancelled' and not((.|ancestor::concept)[lower-case(normalize-space(string(name[@language='nl-NL'])))='prullenbak'])]">
                <xsl:apply-templates select="." mode="createRecords">
                    <xsl:with-param name="compiled-mappings" select="$compiled-mappings"/>
                </xsl:apply-templates> 
            </xsl:for-each>
        </dataset>
        
        <!--now loop over all <record> elements in the already existing fhirmapping-3-2.xml 
            and emit a message if you don't find it in the source (i.e dataset) xml anymore-->
        <xsl:for-each select="$fhirmapping-file/dataset/record">
            <xsl:variable name="dataset-match" select="key('dataset-lookup', ID, $dataset)"/> 
            <xsl:if test="not($dataset-match)">
                <xsl:message>The concept for <xsl:value-of select="naam"/> with id <xsl:value-of select="ID"/> is no longer present in the dataset and is removed from the mapping file</xsl:message>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates a record for each concept</xd:desc>
    </xd:doc>
    <xsl:template match="concept" mode="createRecords">
        <xsl:param name="compiled-mappings" as="document-node()"/>
        <xsl:variable name="id" select="@iddisplay/string()"/>
        <xsl:variable name="concept-name" select="name"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping-file)"/> 
        <xsl:variable name="fhirmapping-profiles" select="key('fhirmapping-lookup', @iddisplay, $compiled-mappings)"/> <!--look up mappings in the bc-profile mappings-->

        <!--variables for comparison-->
        <!-- handling multiple values and/or spaces in fhirmapping -->
        <xsl:variable name="prevMappings" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/mapping, ' ')), '\s+'))"/>
        <xsl:variable name="prevProfiles" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/profile, ' ')), '\s+'))"/>
        <!-- handling multiple values and/or spaces in fhirmapping-profiles -->
        <xsl:variable name="profMappings" select="distinct-values(for $m in $fhirmapping-profiles/mapping return normalize-space($m))"/>
        <xsl:variable name="profProfiles" select="distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space($p))"/>
        <!-- set equality: previous mappings are equal to bc-profile mappings if and only if neither has an item missing in the other -->
        <xsl:variable name="mappings-equal" select="empty($prevMappings[not(. = $profMappings)]) and empty($profMappings[not(. = $prevMappings)])"/>
        <xsl:variable name="profiles-equal" select="empty($prevProfiles[not(. = $profProfiles)]) and empty($profProfiles[not(. = $prevProfiles)])"/>

        <xsl:choose> <!--first choose: tests presence in current fhirmapping-->
            <xsl:when test="empty($fhirmapping)"> <!--a: New dataset concept - the concept does not exist in the previous fhirmapping-->
                <xsl:choose> <!--second choose: tests whether mapping exists in the fhirmapping-profiles-->
                    <xsl:when test="exists($fhirmapping-profiles)"> <!--case a1: a mapping exists in fhirmapping-profiles (doesn't exist in previous mapping)-->
                        <xsl:variable name="profiles-list" select="string-join(distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space(string($p))),', ')"/>
                        <xsl:variable name="line" select="concat('a1: New concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information taken from bc-profile(s): {',$profiles-list,'}.' )"/>
                        <xsl:if test="$debug"><xsl:message select="$line"/></xsl:if>                      
                        <!--there may be multiple mappings in the profile xml's-->
                        <xsl:for-each select="$fhirmapping-profiles">
                            <record>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="name[@language='nl-NL']"/></naam>
                                <mapping><xsl:value-of select="mapping"/></mapping>
                                <profile><xsl:value-of select="profile"/></profile>
                            </record>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise> <!--case a2: a mapping doesn't exist in fhirmapping-profiles (doesn't exist in previous mapping)-->
                        <xsl:variable name="line" select="concat('a2: New concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information not found, to be determined.' )"/>
                        <xsl:if test="$debug"><xsl:message select="$line"/></xsl:if> 
                        <record>
                            <ID><xsl:value-of select="$id"/></ID>
                            <naam><xsl:value-of select="name[@language='nl-NL']"/></naam> 
                            <mapping>to be determined</mapping>
                            <profile>to be determined</profile>
                        </record>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise> <!--b: Existing dataset concept - the concept exists in the previous fhirmapping-->
                <xsl:choose> <!--second choose: tests whether mapping exists in the fhirmapping-profiles AND tests equality of mappings-->
                    <xsl:when test="exists($fhirmapping-profiles) and $mappings-equal and $profiles-equal"> <!--case b1: dataset concept exists in both fhirmappings, and they are equal-->
                        <xsl:variable name="line" select="concat('b1: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information remains unchanged.' )"/>
                        <xsl:if test="$debug"><xsl:message select="$line"/></xsl:if> 
                        <xsl:for-each select="$fhirmapping"> <!--loop over fhirmappings found in fhirmapping xml-->
                            <record>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="$concept-name[@language='nl-NL']"/></naam>         
                                <xsl:if test="mapping[normalize-space()]">
                                    <mapping><xsl:value-of select="mapping"/></mapping>
                                </xsl:if>
                                <xsl:if test="profile[normalize-space()]">
                                    <profile><xsl:value-of select="profile"/></profile>
                                </xsl:if>
                                <xsl:if test="child::in[normalize-space()]">
                                    <in><xsl:value-of select="in"/></in>
                                </xsl:if>
                                <xsl:if test="zib[normalize-space()]">
                                    <zib><xsl:value-of select="zib"/></zib>
                                </xsl:if>            
                                <xsl:if test="example[normalize-space()]">
                                    <example><xsl:value-of select="example"/></example>
                                </xsl:if>            
                                <xsl:if test="searchurl[normalize-space()]">
                                    <searchurl><xsl:value-of select="searchurl"/></searchurl>
                                </xsl:if>
                            </record>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="exists($fhirmapping-profiles)"> <!--case b2: dataset concept exists in both mappings, but with differences-->
                        <xsl:variable name="profiles-list" select="string-join(distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space(string($p))),', ')"/>
                        <xsl:variable name="line" select="concat('b2: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information has been revised, based on bc-profile(s): {',$profiles-list,'}. Recommended to review.')"/>
                        <xsl:if test="$debug"><xsl:message select="$line"/></xsl:if> 
                        <!--the new fhirmapping will follow the profile mappings-->
                        <xsl:for-each select="$fhirmapping-profiles"> <!--loop over fhirmappings found in fhirmapping-profiles-->
                            <record>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="$concept-name[@language='nl-NL']"/></naam>         
                                <xsl:if test="mapping[normalize-space()]">
                                    <mapping><xsl:value-of select="mapping"/></mapping>
                                </xsl:if>
                                <xsl:if test="profile[normalize-space()]">
                                    <profile><xsl:value-of select="profile"/></profile>
                                </xsl:if>
                                <xsl:if test="child::in[normalize-space()]">
                                    <in><xsl:value-of select="in"/></in>
                                </xsl:if>
                                <xsl:if test="zib[normalize-space()]">
                                    <zib><xsl:value-of select="zib"/></zib>
                                </xsl:if>            
                                <xsl:if test="example[normalize-space()]">
                                    <example><xsl:value-of select="example"/></example>
                                </xsl:if>            
                                <xsl:if test="searchurl[normalize-space()]">
                                    <searchurl><xsl:value-of select="searchurl"/></searchurl>
                                </xsl:if>
                            </record>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise> <!--case b3: dataset concept exists in fhirmapping, but not (anymore?) in the bc-profile mappings-->
                        <xsl:variable name="line" select="concat('b3: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information found exclusively in the previous fhirmapping. Recommended to review.' )"/>
                        <xsl:if test="$debug"><xsl:message select="$line"/></xsl:if>
                        <!--the new fhirmapping will follow the previous fhirmappings-->
                        <xsl:for-each select="$fhirmapping"> <!--loop over fhirmappings found in source document-->
                            <record>
                                <ID><xsl:value-of select="$id"/></ID>
                                <naam><xsl:value-of select="$concept-name[@language='nl-NL']"/></naam>         
                                <xsl:if test="mapping[normalize-space()]">
                                    <mapping><xsl:value-of select="mapping"/></mapping>
                                </xsl:if>
                                <xsl:if test="profile[normalize-space()]">
                                    <profile><xsl:value-of select="profile"/></profile>
                                </xsl:if>
                                <xsl:if test="child::in[normalize-space()]">
                                    <in><xsl:value-of select="in"/></in>
                                </xsl:if>
                                <xsl:if test="zib[normalize-space()]">
                                    <zib><xsl:value-of select="zib"/></zib>
                                </xsl:if>            
                                <xsl:if test="example[normalize-space()]">
                                    <example><xsl:value-of select="example"/></example>
                                </xsl:if>            
                                <xsl:if test="searchurl[normalize-space()]">
                                    <searchurl><xsl:value-of select="searchurl"/></searchurl>
                                </xsl:if>
                            </record>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:template>
    
    <xsl:template match="concept" mode="createLogLine">
        <!--this template follows the logic structure of template that matches="concept" in mode="createRecords" but is used to generate a .txt file with log messages -->
        <xsl:param name="compiled-mappings" as="document-node()"/>
        <xsl:variable name="id" select="@iddisplay/string()"/>
        <xsl:variable name="concept-name" select="name"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping-file)"/> 
        <xsl:variable name="fhirmapping-profiles" select="key('fhirmapping-lookup', @iddisplay, $compiled-mappings)"/> <!--look up mappings in the bc-profile mappings-->
        
        <!--variables for comparison-->
        <!-- handling multiple values and/or spaces in fhirmapping -->
        <xsl:variable name="prevMappings" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/mapping, ' ')), '\s+'))"/>
        <xsl:variable name="prevProfiles" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/profile, ' ')), '\s+'))"/>
        <!-- handling multiple values and/or spaces in fhirmapping-profiles -->
        <xsl:variable name="profMappings" select="distinct-values(for $m in $fhirmapping-profiles/mapping return normalize-space($m))"/>
        <xsl:variable name="profProfiles" select="distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space($p))"/>
        <!-- set equality: previous mappings are equal to bc-profile mappings if and only if neither has an item missing in the other -->
        <xsl:variable name="mappings-equal" select="empty($prevMappings[not(. = $profMappings)]) and empty($profMappings[not(. = $prevMappings)])"/>
        <xsl:variable name="profiles-equal" select="empty($prevProfiles[not(. = $profProfiles)]) and empty($profProfiles[not(. = $prevProfiles)])"/>
        
        <xsl:choose> <!--first choose: tests presence in current fhirmapping-->
            <xsl:when test="empty($fhirmapping)"> <!--a: New dataset concept - the concept does not exist in the previous fhirmapping-->
                <xsl:choose> <!--second choose: tests whether mapping exists in the fhirmapping-profiles-->
                    <xsl:when test="exists($fhirmapping-profiles)"> <!--case a1: a mapping exists in fhirmapping-profiles (doesn't exist in previous mapping)-->
                        <xsl:variable name="profiles-list" select="string-join(distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space(string($p))),', ')"/>
                        <xsl:sequence select="concat('a1: New concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information taken from bc-profile(s): {',$profiles-list,'}.' )"/>
                    </xsl:when>
                    <xsl:otherwise> <!--case a2: a mapping doesn't exist in fhirmapping-profiles (doesn't exist in previous mapping)-->
                        <xsl:sequence select="concat('a2: New concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information not found, to be determined.' )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise> <!--b: Existing dataset concept - the concept exists in the previous fhirmapping-->
                <xsl:choose> <!--second choose: tests whether mapping exists in the fhirmapping-profiles AND tests equality of mappings-->
                    <xsl:when test="exists($fhirmapping-profiles) and $mappings-equal and $profiles-equal"> <!--case b1: dataset concept exists in both fhirmappings, and they are equal-->
                        <xsl:sequence select="concat('b1: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information remains unchanged.' )"/>
                    </xsl:when>
                    <xsl:when test="exists($fhirmapping-profiles)"> <!--case b2: dataset concept exists in both mappings, but with differences-->
                        <xsl:variable name="profiles-list" select="string-join(distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space(string($p))),', ')"/>
                        <xsl:sequence select="concat('b2: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information has been revised, based on bc-profile(s): {',$profiles-list,'}. Recommended to review.')"/>
                    </xsl:when>
                    <xsl:otherwise> <!--case b3: dataset concept exists in fhirmapping, but not (anymore?) in the bc-profile mappings-->
                        <xsl:sequence select="concat('b3: Existing concept ',normalize-space(string(name[@language='nl-NL'])), ' with id ',$id, ' is found in the dataset. Mapping information found exclusively in the previous fhirmapping. Recommended to review.' )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:template>
    
    <xsl:template match="node()|@*"/> <!--this is a catch-all empty template that overrides built-in templates-->

</xsl:stylesheet>
