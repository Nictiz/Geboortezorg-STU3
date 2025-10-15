<?xml version="1.0" encoding="UTF-8"?>
<!--this stylesheet updates the existing fhirmapping-3-2 file, and additionally it looks for the mapping information in the bc- profiles-->
<!--TO DO review element 674-->
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"  xmlns:f="http://hl7.org/fhir" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="debug" as="xs:boolean" select="true()"/> <!--TOGGLE BETWEEN true()/false() TO SEE MESSAGE LOGGING-->
    <!--<xsl:param name="compiled-mappings-output" as="xs:string" select="'qa/compiled-mappings-output.xml'"/>-->
    <xsl:param name="compiled-mappings-output" as="xs:string" select="'compiled-mappings-output.xml'"/>
    
    <!-- Point to the 'profiles' folder that contains all bc- profile xml's -->
    <xsl:param name="bc-profile-folder" as="xs:string" select="'../../profiles/'"/>
    <!-- Make it an absolute directory URI, relative to the stylesheet location -->
    <xsl:variable name="bc-profile-folder-uri" as="xs:anyURI" select="resolve-uri($bc-profile-folder, static-base-uri())"/>
    <!-- Load only files matching bc-*.xml in that folder (no subfolders) -->
    <xsl:variable name="bc-profile-files" select="collection(concat($bc-profile-folder-uri,'?select=bc-*.xml;recurse=no;on-error=warning'))"/>
    <xsl:variable name="fhirmapping-file" select="document('../../fhirmapping-3-2.xml')"/>
    
    <xsl:key name="fhirmapping-lookup" match="dataset/record" use="ID"/>
    <xsl:key name="dataset-lookup" match="//concept" use="@iddisplay/string()"/>

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

        <xsl:processing-instruction name="xml-model" select="'href=&quot;qa/fhirmapping.sch&quot; type=&quot;application/xml&quot; schematypens=&quot;http://purl.oclc.org/dsdl/schematron&quot;'" />
        <xsl:variable name="dataset" select="."/>
        <dataset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:copy-of select="@*"/>
            <!--loop over all <concept> elements in your source (i.e. the dataset) xml, and create a record-->
            <xsl:for-each select="$dataset//concept[@type=('group','item') and @statusCode!='cancelled' and not((.|ancestor::concept)[lower-case(normalize-space(string(name[@language='nl-NL'])))='prullenbak']) ]">
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

    <xsl:template match="concept" mode="createRecords">
        <xsl:param name="compiled-mappings" as="document-node()"/>
        <xsl:variable name="id" select="@iddisplay/string()"/>
        <xsl:variable name="concept-name" select="name"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping-file)"/> 
        <xsl:variable name="fhirmapping-profiles" select="key('fhirmapping-lookup', @iddisplay, $compiled-mappings)"/> <!--look up mappings in the bc-profiles-->

        <!-- handling multiple values and/or spaces in fhirmapping -->
        <xsl:variable name="prevMappings" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/mapping, ' ')), '\s+'))"/>
        <xsl:variable name="prevProfiles" select="distinct-values(tokenize(normalize-space(string-join($fhirmapping/profile, ' ')), '\s+'))"/>
        <!-- handling multiple values and/or spaces in fhirmapping-profiles -->
        <xsl:variable name="profMappings" select="distinct-values(for $m in $fhirmapping-profiles/mapping return normalize-space($m))"/>
        <xsl:variable name="profProfiles" select="distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space($p))"/>
        <!-- set equality: previous mappings are equal to bc-profile mappings if and only if neither has an item missing in the other -->
        <xsl:variable name="mappings-equal" select="empty($prevMappings[not(. = $profMappings)]) and empty($profMappings[not(. = $prevMappings)])"/>
        <xsl:variable name="profiles-equal" select="empty($prevProfiles[not(. = $profProfiles)]) and empty($profProfiles[not(. = $prevProfiles)])"/>

        <xsl:choose> <!--first choose based on presence in fhrimapping-->
            <xsl:when test="empty($fhirmapping)"> <!--a: New dataset concept - the concept does not exist in the previous fhirmapping-->
                <xsl:choose> <!--second choose based on whether mapping exists in the fhirmapping-profiles-->
                    <xsl:when test="exists($fhirmapping-profiles)"> <!--case a1: a mapping exists in fhirmapping-profiles-->
                        <xsl:variable name="profiles-list" select="string-join(distinct-values(for $p in $fhirmapping-profiles/profile return normalize-space(string($p))),', ')"/>
                        <xsl:message>a1: New concept <xsl:value-of select="name"/> with id <xsl:value-of select="$id"/> is found in the dataset. Mapping information found in bc-profile(s): {<xsl:value-of select="$profiles-list"/>} and is added to the mapping file</xsl:message>
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
                    <xsl:otherwise> <!--case a2: a mapping doesn't exist in fhirmapping-profiles-->
                        <xsl:message>a2: New concept <xsl:value-of select="name"/> with id <xsl:value-of select="$id"/> is found in the dataset. No mapping information found in bc-profiles, to be determined</xsl:message>
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
                <xsl:choose> <!--second choose-->
                    <xsl:when test="exists($fhirmapping-profiles) and $mappings-equal and $profiles-equal"> <!--case b1: dataset concept exists in both fhirmappings, and they are equal-->
                        <xsl:message>b1: dataset concept <xsl:value-of select="naam"/> with id <xsl:value-of select="ID"/> exists</xsl:message>
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
                        <xsl:message>b2: Concept <xsl:value-of select="naam"/> with id <xsl:value-of select="ID"/> has a revised mapping in the current bc-profiles which will be leading for the resulting fhirmapping. Review done?</xsl:message>
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
                    <xsl:otherwise> <!--case b3: dataset concept exists in fhirmapping, but not anymore in the bc-profile mappings-->
                        <xsl:message>b3: Concept <xsl:value-of select="naam"/> with id <xsl:value-of select="ID"/> is not mapped in the current bc-profiles. The previous fhirmapping will be leading for the resulting output. Recommended to review</xsl:message>
                        <!--the new fhirmapping will follow the profile mappings-->
                        <xsl:for-each select="$fhirmapping"> <!--loop over fhirmappings found in fhirmapping-profiles-->
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
    
    <xsl:template match="node()|@*"/> <!--this is a catch-all empty template that overrides built-in templates-->

</xsl:stylesheet>
