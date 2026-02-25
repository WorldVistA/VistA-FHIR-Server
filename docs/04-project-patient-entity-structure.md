Based on the metadata provided in your registry, here is a structured technical outline of the **C0FHIR PATIENT (#267)** entity.

This entity acts as a "root" or "parent" object that orchestrates the data collection from multiple VistA files by calling various sub-entities.

---

## ## C0FHIR PATIENT Entity Structure

### ### 1. Primary Metadata

* **Entity Name:** `C0FHIR PATIENT`
* **Data Model:** `FHIR`
* **Default File:** `2` (PATIENT)
* **Core ID Action:** `S DFN=DIEN D DEM^VADPT,OPD^VADPT` (Initializes demographic and other patient data arrays).

---

### ### 2. Included Sub-Entities (Nesting)

The `C0FHIR PATIENT` entity includes several child entities to build the full FHIR Patient resource. These are triggered via the **ITEM TYPE: ENTITY** definition:

* **`C0FHIR NAME` (#268):** Parses the `.01` field using `NAMECOMP^XLFNAME` to separate Family, Given, and Middle names.
* **`C0FHIR PATIENT ALIAS` (#271):** Iterates through the Alias sub-file (**#2.01**) to capture alternate names.
* **`C0FHIR PATIENT ADDRESS` (#269):** * Maps permanent and temporary addresses.
* Includes **`C0FHIR PATIENT ADDRESS EXT` (#270)** to handle the Bad Address Indicator.


* **`C0FHIR PATIENT NUMBER` (#292):** Generates complex identifier strings for SSN, MRN, and ICN.
* **`C0FHIR RACE` (#303) & `C0FHIR ETHNICITY` (#302):**
* Uses **`C0FHIR CDC EXTENSION` (#320)** to map VistA codes to standard CDC/HL7 terminology.


* **`C0FHIR LANGUAGE` (#301):** Pulls from the Language sub-file (**#2.07**) to identify primary and other languages.
* **`C0FHIR FAMILY DOCTOR` (#300):** Resolves the Primary Care Physician from the PCMM logic (`$$OUTPTPR^SDUTL3`).

---

### ### 3. Data Element Mappings (Direct & Transformed)

| Property | VistA Source | Transformation / Action |
| --- | --- | --- |
| **BirthTime** | Field `.03` | `S VALUE=$$DATE^VPRSDA(VALUE)` (ISO-8601) |
| **Gender** | Field `.02` | Maps internal codes (M/F) via `C0FHIR CODE TABLE`. |
| **MaritalStatus** | Field `.05` | Maps internal FileMan codes to **HL7 Table 0002**. |
| **DeathTime** | Field `.351` | Populates `deceasedDateTime` if applicable. |
| **IsProtected** | File `38.1` | Sets the FHIR Security Label for sensitivity. |

---

### ### 4. Support Contacts (Sub-Tree)

The entity manages a complex list of "SupportContacts" by calling specific sub-entities for each relationship type:

* **`C0FHIR PATIENT NOK` (#288):** Next of Kin.
* **`C0FHIR PATIENT ECON` (#275):** Emergency Contact.
* **`C0FHIR PATIENT NOK2` (#290) / `ECON2` (#277):** Secondary contacts.

---

### ### 5. Performance & Execution Logic

* **GET ENTRY ACTION:** Checks for site station numbers and sets station variables (`VASTN`).
* **GET EXIT ACTION:** Cleans up `VA`, `VADM`, `VAPD`, and `VPRPHONE` variables to prevent memory leaks in the partition.
* **Aggregator Integration:** When running Build 2, this entity is optimized by the **Sealer (`C0FHIRSL`)**, allowing `C0FHIRGF` to generate the JSON bundle without re-calculating the FileMan logic at runtime.

---

**Would you like me to generate the Mumps "Loader" routine logic for a specific child entity, such as `C0FHIR PATIENT NUMBER`, to ensure the ICN and SSN are formatted correctly for R4?**