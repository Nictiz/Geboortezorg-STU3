# Set the right path to your profile folder and output folder
# Run the script to create snapshots and add mappings from the xml mapping file
# Open the output folder in Forge, select all profiles and open them so Forge will recreate their differentials
# Save all files in Forge (check if they are saved correctly, in some cases there are still constraints from the parent profile in the differential, reopening and saving in Forge helps to solve this)
# Check if all files are in the right format (elements may contain prefixes, this can be fixed with replace all in files)
# Run checkmappings.xsl to check if all mappings are correct (in some cases mappings can be missed, for example when extensions inherited from the parent profile have no constraints in the derived profile)

from asyncio.windows_events import NULL
import json
from jsonpath_ng import jsonpath, parse
import logging
# from logging import exception``1
from operator import truediv
import xml
import xmltodict, json
#from dicttoxml import dicttoxml
import xml.etree.ElementTree as ET
from bs4 import BeautifulSoup
from fhirclient import client, models
import fhirclient.models.structuredefinition as p
import fhirclient.models.elementdefinition as ed
import os
import glob
path = "C:\Git\\Geboortezorg-STU3\profiles\\"
outputFolderSnapshots = "generatedSnapshots\\"
outputFolderGeneratedProfiles = "generatedProfiles\\"
xmlFileList = [f.partition(path)[2] for f in glob.glob(path+"*.xml")]
with open("C:\Git\\Geboortezorg-STU3\\fhirmapping-3-2.xml") as fp:
    mappingFile = BeautifulSoup(fp, 'xml')

#load xml file from disk, generate snapshot and save it as xml file
def prepare_file(fileName):
    os.system('cmd /c "cd '+path+' & fhir push '+fileName+' & fhir snapshot & fhir save '+outputFolderSnapshots+fileName+' --xml" & fhir clear')
    print('snapshot generated and saved as '+path+outputFolderSnapshots+fileName)

#get a list of all xml files in directory and prepare the file
for f in xmlFileList:
    print(f)
    prepare_file(f)

#load and transform files
for f in xmlFileList:
    print(f)
    profile = ET.parse(path+outputFolderSnapshots+f)
    root = profile.getroot()
    root.remove(root.find("./{http://hl7.org/fhir}differential"))
    print('removed differential from profile')
    #check if mapping at profile level exists
    profileMapping = root.findall("./{http://hl7.org/fhir}mapping/{http://hl7.org/fhir}identity[@value='gebz-peri-v3.2']/..")
    if profileMapping == []:
        #if not, add the mapping at profile level
        mapping = ET.Element('{http://hl7.org/fhir}mapping')
        identity = ET.SubElement(mapping, '{http://hl7.org/fhir}identity').set('value','gebz-peri-v3.2')
        uri = ET.SubElement(mapping, '{http://hl7.org/fhir}uri').set('value','https://decor.nictiz.nl/art-decor/decor-datasets-\\-peri20-?id=2.16.840.1.113883.2.4.3.11.60.90.77.1.6&effectiveDate=2016-09-08T00%3A00%3A00&conceptId=2.16.840.1.113883.2.4.3.11.60.90.77.2.6.4&conceptEffectiveDate=2016-09-08T00%3A00%3A00')
        name = ET.SubElement(mapping, '{http://hl7.org/fhir}name').set('value','Geboortezorg 3.2')
        root.append(mapping)
        print('mapping with identity gebz-peri-v3.2 added at profile level')
    #clean up old element mappings first
    profileElements = root.findall("./{http://hl7.org/fhir}snapshot/{http://hl7.org/fhir}element")
    for e in profileElements:
        for em in e.findall("{http://hl7.org/fhir}mapping/{http://hl7.org/fhir}identity[@value='gebz-peri-v3.2']/.."):
            e.remove(em)
    print('removed element mappings')
    #get all element level mappings from the mapping file for this profile
    profileList = mappingFile.find_all("profile", text=root.find('{http://hl7.org/fhir}id').attrib['value'])
    count = 0
    for pl in profileList:
        record = pl.find_parent("record")
        fhirMapping = record.mapping.text
        #loop through profile snapshot elements
        for e in profileElements: 
            #check of id element overeenkomt met mapping in de mapping file...........
            if(e.attrib['id'] == fhirMapping):
            #if(e.find("{http://hl7.org/fhir}identity[@value='gebz-peri-v3.2']") and em.find("{http://hl7.org/fhir}map[@value='+{record.ID.text}']")):
                elementMapping = ET.Element('{http://hl7.org/fhir}mapping')
                identity = ET.SubElement(elementMapping, '{http://hl7.org/fhir}identity').set('value','gebz-peri-v3.2')
                map = ET.SubElement(elementMapping, '{http://hl7.org/fhir}map').set('value',record.ID.text)
                comment = ET.SubElement(elementMapping, '{http://hl7.org/fhir}comment').set('value',record.naam.text)
                e.append(elementMapping)
                count += 1
    print(str(count) + ' mappings with identity gebz-peri-v3.2 added at element level')
    tree = ET.ElementTree(root)
    ET.indent(tree, space="\t", level=0)
    tree.write(path+outputFolderGeneratedProfiles+f, encoding="utf-8")
    print('file saved as'+path+outputFolderGeneratedProfiles+f)
