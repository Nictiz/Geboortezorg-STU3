# Geboortezorg-STU3

This repository contains HL7 FHIR STU3 compliant profiles based on PWD 2.3 and PWD 3.2. There is a dependency on the Nictiz-STU3-Zib2017 profiles, which are based on the Release 2017 of the Dutch Clinical Building Blocks / Healthcare Information models (Dutch: [Zorginformatiebouwsteen or ZIB](https://zibs.nl/wiki/Zorginformatiebouwstenen "Zorginformatiebouwstenen")).

The Dutch National ICT institute in the Netherlands (Nictiz) maintains this repository and its contents. 

Please be aware that this repository contains draft materials such as newly designed FHIR profiles that have not gone through a complete review process. Draft materials are differentiated from normative materials by a FHIR status of ‘draft’ and a business version lower than 1.0.0. Normative materials will have an ‘active’ FHIR status.

[![Firely Validation](https://github.com/Nictiz/Geboortezorg-STU3/actions/workflows/main.yml/badge.svg)](https://github.com/Nictiz/Geboortezorg-STU3/actions/workflows/main.yml)
- - - -

## Git workflow

### Branching strategy

Since July 2022, the branch "stable-1.x" (default on GitHub) is considered the stable branch, not "master". The reason for this is that there may be multiple stable branches being maintained simultaniously. This branch corresponds to the HL7 FHIR package that Nictiz publishes.

Nictiz uses the following branching strategy for development:
* Releases correspond with the "stable-xxx" branches. These branches are only updated when there is a new release.
* Integration of fixes and features is done on integration branches, called "release-xxx", where "xxx" is the version number of the upcoming release. Integration branches are created for each new release cycle and deleted after they are merged to the "stable-xxx" branches.
* Development of fixes and features is done:
	* Hotfixes (typo's etc.) are usually directly applied on the integration branch(es).
	* Larger issues are developed in topic branches. These issues are usually tracked in [BITS](https://bits.nictiz.nl) and the topic branches are called accordingly. Topic branches are merged into the integration branches when they are ready to be released. They are deleted after they are merged to all relevant integration branches.
	* _NOTE: version numbers of FHIR materials should not be changed as part of the development process. This should be part of the release process._

The following illustration visualizes how this workflow might look like
```
stable-1.x
-----x-----------------x------------+--x-----------------
     |                 |            |  |
     | release-1.3.5   |            |  | release-1.3.6
     \----x---------+--|------------/  \-----+-----------
          |         |  |                     |
          | GZ-1024 |  | GZ-2048             |
          \---------/  \--\------------------/
                          |
stable-2.x                |
---------x----------------|----+--x----------------------
         |                |    |  |
         | release-2.0.1  |    |  | release-2.0.2
         \--x---------+---+----/  \----------------------
            |         |
            | GZ-4096 |
            \---------/
```
Things to note:
* Both major versions have independent life cycles. For example, the release cycle for 2.0.1 starts and ends at a different point in time than the release cycle for 1.3.5.
* Topic branches may be branched from a release branch (GZ-1024) or a stable branch (GZ-2048), at the developer's discretion.
* Topic branches may be relevant for a single major version (GZ-1024, GZ-4096) or both major versions (GZ-2048). For a merge to the "non-native" branch, cherry-picking or (preferably) a `rebase --onto` is required (for example: `git rebase --onto release-2.0.1 stable-1.x GZ-2048` before merging GZ-2048 into release-2.0.1).
* Topic branches may have a life cycle independent from the releases (GZ-2048).
