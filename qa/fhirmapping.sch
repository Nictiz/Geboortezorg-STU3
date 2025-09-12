<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3">
    <!-- ======================================================================= -->
    <!-- 
       fhirmapping.sch 
       
       TBD
    -->
    <!-- ======================================================================= -->
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
    <!-- ======================================================================= -->
    
    <pattern>
        
        <rule context="record">
            <let name="precedingMatch" value="preceding-sibling::record[ID = current()/ID][profile = current()/profile]"/>
            <report role="warning" test="$precedingMatch"
                >This record for <value-of select="ID"/> - <value-of select="naam"/> duplicates another for the same profile <value-of select="if ($precedingMatch/mapping = mapping) then 'and the same path' else 'but different paths'"/>. Please check.</report>
        </rule>
    </pattern>
</schema>
