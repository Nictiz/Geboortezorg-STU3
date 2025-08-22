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
        <xd:desc>Produces valuesets from FHIR mapping in a folder ValueSets next to this XSL
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
        
        <xsl:call-template name="doValueSetsForCode"/>
        
    </xsl:template>
    
    <xsl:template name="doValueSetsForCode">
        
        <!-- These concepts do not have a parent mapping onto the resource level to we they directly go into e.g. Observation.value -->
        <xsl:variable name="valueConcepts" as="element()*">
            <record id="peri32-dataelement-1729">Datum einde zwangerschap</record>
            <record id="peri32-dataelement-2913">SociaalNetwerk</record>
            <record id="peri32-dataelement-10774">UrinatieGeweest?</record>
            <record id="peri32-dataelement-10775">DefecatieGeweest?</record>
            <record id="peri32-dataelement-3115">Lochia foetide / riekend?</record>
            <record id="peri32-dataelement-3117">Grote stolsels in lochia (Waarde)</record>
        </xsl:variable>
        <!-- Get fhirmapping records - grouped per profile - that map into bc profiles at root resource level, e.g. Condition or Observation -->
        <xsl:for-each-group select="$fhirmapping-file/record[string-length(profile[starts-with(., 'bc-')]) gt 0][not(contains(mapping, '.')) or ID = $valueConcepts/@id]" group-by="profile">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:variable name="mappingRecords" as="element(record)+" select="current-group()"/>
            
            <!-- Get the relevant StructureDefinition (profile) -->
            <xsl:variable name="theProfile" select="$all-profiles[ends-with(f:url/@value, current-grouping-key())]" as="element(f:StructureDefinition)"/>
            <!-- Get the current ValueSet for the -code element. Expect [profile.name]-code as its name -->
            <xsl:variable name="theValueSet" select="$valueSets[ends-with(f:url/@value, concat(current-grouping-key(), '-code'))]" as="element(f:ValueSet)?"/>
            
            <!-- If there is no current value set for the profile, then skip the rest. Apparently no such ValueSet is needed for this profile -->
            <xsl:if test="$theValueSet">
                
                <!-- Get the terminologyAssociations from the dataset (ADA Release file). These are not always attached to the concept mentioned in the fhirmapping record. They might be connected to a specific child concept -->
                <xsl:variable name="terminologyAssociations" as="element()*">
                    <xsl:for-each select="$mappingRecords/ID">
                        <xsl:variable name="theConcept" select="nf:getDataConcept(.)"/>
                        <xsl:choose>
                            <xsl:when test="$theConcept/concept[name[. = 'ProbleemNaam']]/valueSet">
                                <xsl:sequence select="$theConcept/concept[name[. = 'ProbleemNaam']]/valueSet/terminologyAssociation[@valueSet]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'VerrichtingType']]/valueSet">
                                <xsl:sequence select="$theConcept/concept[name[. = 'VerrichtingType']]/valueSet/terminologyAssociation[@valueSet]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'ObservatieNaam']]/valueSet">
                                <xsl:sequence select="$theConcept/concept[name[. = 'ObservatieNaam']]/valueSet/terminologyAssociation[@valueSet]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'SonomarkerNaam']]/valueSet">
                                <xsl:sequence select="$theConcept/concept[name[. = 'SonomarkerNaam']]/valueSet/terminologyAssociation[@valueSet]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'Schooltype']]">
                                <xsl:sequence select="$theConcept/concept[name[. = 'Schooltype']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept[name[. = 'Maternale sterfte']]">
                                <xsl:sequence select="$theConcept/concept[name[. = 'OverlijdensIndicator']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)][@code = '59283008']"/>
                            </xsl:when>
                            <xsl:when test="$theConcept[name[. = 'Perinatale sterfte']]">
                                <xsl:sequence select="$theConcept/concept[name[. = 'OverlijdensIndicator']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)][not(@code = '59283008')]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'ZelfredzaamheidAndersDanVerwachting']]">
                                <xsl:sequence select="$theConcept/concept[name[. = 'ZelfredzaamheidAndersDanVerwachting']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept[name[. = 'Continentie']]">
                                <xsl:sequence select="$theConcept/concept[name[. = ('UrineContinentie', 'FecesContinentie', 'Flatusincontinentie')]]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[. = 'ATermeDatum']]">
                                <xsl:sequence select="$theConcept/concept[name[. = 'ATermeDatum']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]">
                                <xsl:sequence select="$theConcept/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/valueSet">
                                <xsl:sequence select="$theConcept/valueSet"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[ends-with(., 'Waarde')]]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]">
                                <xsl:sequence select="$theConcept/concept[name[ends-with(., 'Waarde') or . = 'ProbleemNaam']]/terminologyAssociation[@conceptId = (../@id | ../inherit/@ref)]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept/concept[name[ends-with(., 'Waarde')]]">
                                <xsl:sequence select="$theConcept/concept[name[ends-with(., 'Waarde') or . = 'ProbleemNaam']]/valueSet/terminologyAssociation[@valueSet]"/>
                            </xsl:when>
                            <xsl:when test="$theConcept[valueDomain | concept[valueDomain][not(contains)]]">
                                <xsl:message><xsl:value-of select="current-grouping-key()"/><xsl:text>: MISSING association for </xsl:text><xsl:value-of select="."/><xsl:text> </xsl:text><xsl:value-of select="$theConcept/(name[@language = 'nl-NL'], name)[1]"/></xsl:message>
                            </xsl:when>
                            <!--<xsl:otherwise>
                                <xsl:message><xsl:value-of select="current-grouping-key()"/><xsl:text>: NO TRANSACTION for </xsl:text><xsl:value-of select="."/></xsl:message>
                            </xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                
                <!-- Check the current ValueSet for things - concepts and/or value sets - that will not be present in the new data. We will copy those into the new value set as comments -->
                <xsl:variable name="extraTerminologyAssociations" select="$theValueSet/f:compose/f:include/f:concept[not(f:code/@value = $terminologyAssociations/@code)] | 
                                                                          $theValueSet/f:compose/f:include/f:valueSet[not(substring-before(tokenize(@value, '/')[last()], '--') = $terminologyAssociations/@valueSet)]" as="element()*"/>
                
                <!-- Start building the ValueSet -->
                <xsl:message>Creating <xsl:value-of select="$outputdir"/>/ValueSets/<xsl:value-of select="current-grouping-key()"/>-code.xml ...</xsl:message>
                <xsl:result-document href="{$outputdir}/ValueSets/{current-grouping-key()}-code.xml" indent="yes" omit-xml-declaration="yes">
                    <ValueSet xmlns="http://hl7.org/fhir">
                        <id value="{current-grouping-key()}-code"/>
                        <meta>
                            <profile value="http://hl7.org/fhir/StructureDefinition/shareablevalueset"/>
                        </meta>
                        <url value="http://nictiz.nl/fhir/ValueSet/{current-grouping-key()}-code"/>
                        <version value="1.3.3"/>
                        <name value="{current-grouping-key()}-code"/>
                        <title value="{current-grouping-key()}-code"/>
                        <status value="draft"/>
                        <experimental value="false"/>
                        <publisher value="Nictiz"/>
                        <description value="{current-grouping-key()}-code"/>
                        <immutable value="false"/>
                        <copyright value="This artefact includes content from SNOMED Clinical Terms® (SNOMED CT®) which is copyright of the International Health Terminology Standards Development Organisation (IHTSDO). Implementers of these artefacts must have the appropriate SNOMED CT Affiliate license - for more information contact http://www.snomed.org/snomed-ct/getsnomed-ct or info@snomed.org."/>
                        <compose>
                            <!-- Create compose.include elements per code system -->
                            <xsl:for-each-group select="$terminologyAssociations[@code][@codeSystem]" group-by="@codeSystem">
                                <include>
                                    <system value="{local:getUri(current-grouping-key())}"/>
                                    
                                    <!-- Create include.concept elements preventing duplicates -->
                                    <xsl:for-each-group select="current-group()" group-by="@code">
                                        <!--<xsl:comment><xsl:text> </xsl:text><xsl:value-of select="../@iddisplay"/><xsl:text> </xsl:text><xsl:value-of select="../(name[@language = 'nl-NL'], name)[1]"/><xsl:text> </xsl:text></xsl:comment>-->
                                        <concept>
                                            <!-- http://hl7.org/fhir/StructureDefinition/valueset-comments would have worked, but only for this context and not for include.valueSet
                                                    https://jira.hl7.org/browse/FHIR-51904 -->
                                            <extension url="http://nictiz.nl/fhir/StructureDefinition/Comment">
                                                <valueString value="{../@iddisplay,../(name[@language = 'nl-NL'], name)[1]}"/>
                                            </extension>
                                            <code value="{current-grouping-key()}"/>
                                            <display value="{current-group()[1]/@displayName}"/>
                                        </concept>
                                    </xsl:for-each-group>
                                </include>
                            </xsl:for-each-group>
                            <!-- Create compose.include elements per valueSet preventing duplicates ... technically they could be in a single include but left it the way I found it -->
                            <xsl:for-each-group select="$terminologyAssociations[@valueSet]" group-by="@valueSet">
                                
                                <!-- If the terminologyAssociation has flexibility dynmic we might be able to get it from the valueSet ... but if the concept has multiple valueSets 
                                    connected, then those are merged into a single valueSet which looses the metadata from all but 1 valueSet. so as last resort we might be able to 
                                    check the exported set of ValueSets where our target probably exists: error if all fails -->
                                <xsl:variable name="valueSetEffectiveDate" as="attribute()">
                                    <xsl:choose>
                                        <xsl:when test="current-group()/@flexibility[. castable as xs:dateTime]">
                                            <xsl:sequence select="current-group()/@flexibility[. castable as xs:dateTime]"/>
                                        </xsl:when>
                                        <xsl:when test="current-group()/parent::valueSet[@id = current-grouping-key()]/@effectiveDate">
                                            <xsl:sequence select="current-group()/parent::valueSet[@id = current-grouping-key()]/@effectiveDate"/>
                                        </xsl:when>
                                        <xsl:when test="$allValueSets[f:url[contains(@value, concat('/', current-grouping-key()))]]">
                                            <xsl:sequence select="$allValueSets[f:url[contains(@value, concat('/', current-grouping-key()))]]/f:extension[@url='http://hl7.org/fhir/StructureDefinition/resource-effectivePeriod']/f:valuePeriod/f:start/@value"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:message>NOT FOUND effectiveDate for ValueSet <xsl:value-of select="current-grouping-key()"/><xsl:text> </xsl:text><xsl:value-of select="current-group()[1]/@valueSetName"/></xsl:message>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <!--<xsl:comment><xsl:text> </xsl:text><xsl:value-of select="ancestor::concept[1]/@iddisplay"/><xsl:text> </xsl:text><xsl:value-of select="ancestor::concept[1]/(name[@language = 'nl-NL'], name)[1]"/><xsl:text> </xsl:text></xsl:comment>-->
                                <include>
                                    <valueSet value="http://decor.nictiz.nl/fhir/ValueSet/{current-grouping-key()}--{replace($valueSetEffectiveDate[1], '\D', '')}">
                                        <extension url="http://nictiz.nl/fhir/StructureDefinition/Comment">
                                            <valueString value="{ancestor::concept[1]/@iddisplay, ancestor::concept[1]/(name[@language = 'nl-NL'], name)[1]}"/>
                                        </extension>
                                    </valueSet>
                                </include>
                            </xsl:for-each-group>
                            
                            <!-- Some of the existing ValueSets for -code have include of full code system (normally LOINC). Not sure why but keep those as we will not get that knowledge from the dataset -->
                            <xsl:copy-of select="$theValueSet/f:compose/f:include[f:system][empty(f:concept | f:valueSet)]"/>
                            
                            <!-- If there is more terminology in the original value set then we currently have, we check what profile this temrinology should now be in by looking up the dataset concept 
                                that this terminology belongs to, and subsequently the mapping(s) this concept has. If the terminology is connected to a concept that also maps into the current profile, then
                                it is added as comment in the new ValueSet. This should be looked into, as there should not be any comment like that. Any terminology relevant for the current profile should 
                                have been captured in $terminologyAssociations  -->
                            <xsl:for-each select="$extraTerminologyAssociations">
                                <xsl:variable name="associatedConcept" select="$ada-release-file//concept[terminologyAssociation/@code = current()/f:code/@value] | 
                                                                               $ada-release-file//concept[terminologyAssociation/@valueSet = current()/substring-before(tokenize(@value, '/')[last()], '--')] |
                                                                               $ada-release-file//concept[valueSet//@code = current()/f:code/@value]"/>
                                <xsl:variable name="associatedMapping" select="$fhirmapping-file//record[ID = $associatedConcept/@iddisplay]/profile"/>
                                <xsl:if test="$associatedMapping = $theProfile/f:name/@value">
                                    <xsl:comment>
                                        <xsl:for-each-group select="$associatedConcept" group-by="@id">
                                            <xsl:value-of select="current-group()[1]/@iddisplay"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="(name[@language = 'nl-NL'], name)[1]"/>
                                            <xsl:text> in profile "</xsl:text>
                                            <xsl:value-of select="$fhirmapping-file//record[ID = current()/@iddisplay]/profile"/>
                                            <xsl:text>"</xsl:text>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>
          </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each-group>
                                    </xsl:comment>
                                    <xsl:choose>
                                        <xsl:when test="f:code">
                                            <xsl:comment>
                                            <xsl:text>&lt;concept&gt;
              </xsl:text>
                                            <xsl:text>&lt;code value="</xsl:text>
                                            <xsl:value-of select="f:code/@value"/>
                                            <xsl:text>"/&gt;
              </xsl:text>
                                            <xsl:text>&lt;display value="</xsl:text>
                                            <xsl:value-of select="f:display/@value"/>
                                            <xsl:text>"/&gt;
          </xsl:text>
                                            <xsl:text>&lt;/concept&gt;</xsl:text>
                                        </xsl:comment>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:comment>
                                            <xsl:text>&lt;valueSet value="</xsl:text>
                                            <xsl:value-of select="replace(@value, '--', '-\\-')"/>
                                            <xsl:text>"/&gt;</xsl:text>
                                        </xsl:comment>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:comment>=========================================================</xsl:comment>
                                </xsl:if>
                                
                                <xsl:message>
                                    <xsl:value-of select="$theProfile/f:name/@value"/><xsl:text>-code WARNING: NOT including </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="self::f:valueSet">
                                            <xsl:text>ValueSet </xsl:text><xsl:value-of select="@value"/>
                                        </xsl:when>
                                        <xsl:when test="self::f:concept">
                                            <xsl:text>Code </xsl:text><xsl:value-of select="f:code/@value"/>
                                            <xsl:text> - </xsl:text><xsl:value-of select="f:display/@value"/>
                                            <xsl:text> - </xsl:text><xsl:value-of select="../f:system/@value"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:text>
</xsl:text>
                                    <xsl:text>    Concept(s):</xsl:text>
                                    <xsl:for-each-group select="$associatedConcept" group-by="@id">
                                        <xsl:variable name="associatedProfile" select="$fhirmapping-file//record[ID = current()/@iddisplay]/profile"/>
                                        <xsl:text>
    </xsl:text>
                                        <xsl:value-of select="current-group()[1]/@iddisplay"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="(name[@language = 'nl-NL'], name)[1]"/>
                                        <xsl:text> in</xsl:text>
                                        <xsl:if test="$associatedProfile != $theProfile/f:name/@value"> a different</xsl:if>
                                        <xsl:text> profile "</xsl:text>
                                        <xsl:value-of select="$fhirmapping-file//record[ID = current()/@iddisplay]/profile"/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each-group>
                                    <xsl:if test="empty($associatedConcept)">
                                        <xsl:text>    | not found in transactions |</xsl:text>
                                    </xsl:if>
                                </xsl:message>
                            </xsl:for-each>
                        </compose>
                    </ValueSet>
                    
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
        
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