<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    
    <xsl:variable name="fhirmapping-file" select="document('../../fhirmapping-3-2.xml')"/>
    <xsl:key name="fhirmapping-lookup" match="dataset/record" use="ID"/>
    <xsl:key name="dataset-lookup" match="//concept" use="@iddisplay/string()"/>


    <xsl:template match="dataset">
        <xsl:processing-instruction name="xml-model" select="'href=&quot;qa/fhirmapping.sch&quot; type=&quot;application/xml&quot; schematypens=&quot;http://purl.oclc.org/dsdl/schematron&quot;'" />
        <xsl:variable name="dataset" select="."/>
        <dataset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:copy-of select="@*"/>
            <!--loop over all <concept> elements in your source (i.e. the dataset) xml, and create a record-->
            <xsl:for-each select="$dataset//concept[@type=('group','item') and @statusCode!='cancelled' and not((.|ancestor::concept)[lower-case(normalize-space(string(name[@language='nl-NL'])))='prullenbak']) ]">
                <xsl:apply-templates select="." mode="createRecords"/> 
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
        <xsl:variable name="id" select="@iddisplay/string()"/>
        <xsl:variable name="concept-name" select="name"/>
        <xsl:variable name="fhirmapping" select="key('fhirmapping-lookup', @iddisplay, $fhirmapping-file)"/>  
        <xsl:if test="not($fhirmapping)">
            <xsl:message>A new concept for <xsl:value-of select="name"/> is found with id <xsl:value-of select="$id"/> and is added to the mapping file</xsl:message>
            <record>
                <ID><xsl:value-of select="$id"/></ID>
                <naam><xsl:value-of select="name[@language='nl-NL']"/></naam> 
                <mapping>to be determined</mapping>
                <profile>to be determined</profile>
            </record>
        </xsl:if>
        <xsl:for-each select="$fhirmapping"> <!--will loop over fhirmappings found in fhirmapping xml-->
            <record>
                <ID><xsl:value-of select="$id"/></ID>
                <naam><xsl:value-of select="$concept-name[@language='nl-NL']"/></naam>         
                <xsl:if test="mapping[normalize-space()]">
                    <mapping><xsl:value-of select="mapping"/></mapping>
                </xsl:if>
                <xsl:if test="profile[normalize-space()]">
                    <profile><xsl:value-of select="profile"/></profile>
                </xsl:if>
                <xsl:if test="in[normalize-space()]">
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

    </xsl:template>
    
    <xsl:template match="node()|@*"/> <!--catch-all empty template that overrides built-in templates-->

</xsl:stylesheet>
