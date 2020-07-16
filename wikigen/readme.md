# Wiki  generator for community fhirmapping
The fhirmapping is based on a community in ART-DECOR, fhirmapping:
https://decor.nictiz.nl/art-decor/decor-mycommunity--peri20-?name=fhirmapping&language=nl-NL
(now partially filled for dataset 2.3)

The definition can be found here:
https://raw.githubusercontent.com/Nictiz/Geboortezorg-STU3/master/generator/fhirmapping-definition.xml

With the FHIR mapping, a base profile, FHIR example, and REST example is provided with each concept.

From this is generated:
- a profile mapping
  - see example at: https://informatiestandaarden.nictiz.nl/wiki/Gebz:V2.3_FHIR_mapping_addendum
  - the sections are included on other pages as well, so a single addendum can be generated and used in other places
- a transaction list
  - see example at: https://informatiestandaarden.nictiz.nl/wiki/Gebz:FHIR_IG#List_of_StructureDefinitions

Generation is done in three steps:
1. Download RetrieveTransaction dataset or transaction
1. Generate a maps/map/mapping file
1. Generate wiki content

Stylesheets:
1. release_2_fhir_profile_mapping:
Takes a compiled dataset (RetrieveTransaction) with a community 'fhirmapping', outputs a maps/map

2. profile_mapping_2_wiki:
Takes above map and makes a wiki page with a section for each map. In that section a table with:
- Type 
- Id 
- Concept
- Profile
- System 
- Code
- Display 
- FHIR type 
- system+code 
- unit

3. release_2_fhir_transaction_list:
Takes a compiled transaction (RetrieveTransaction) with a community 'fhirmapping', outputs a map

4. transaction_list_2_wiki:
Takes above map and makes a wiki table for that transaction with:
- Type 
- Id 
- Concept
- Card 
- Profile
- Example
- Search URL