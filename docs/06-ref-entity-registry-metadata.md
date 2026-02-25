To make the **Entity File (#1.5)** scannable for your project, I have reformatted the raw text into a structured, hierarchical technical reference. I’ve grouped the entities by their clinical purpose and focused on the **FHIR-specific** mappings you’ve been building.

---

# # VistA Entity Registry Metadata (File #1.5)

**Project:** C0FHIR R4 Integration

**Model Focus:** FHIR / SDA

**Release Date:** Feb 21, 2026

---

## ## I. Core Administrative & Identity (Patient)

These entities form the backbone of the Patient resource, using `VADPT` calls and Kernel name utilities.

### ### Entity: **C0FHIR PATIENT** (#267)

* **Source File:** 2 (PATIENT)
* **ID Action:** `S DFN=DIEN D DEM^VADPT,OPD^VADPT`
* **Key Sub-Entities (Nesting):**
* **C0FHIR NAME:** Parses `.01` into Family/Given.
* **C0FHIR PATIENT ALIAS:** Aliases from subfile 2.01.
* **C0FHIR PATIENT NUMBER:** Maps SSN, MRN, and ICN.
* **C0FHIR RACE / ETHNICITY:** Standardized CDC mappings.
* **C0FHIR LANGUAGE:** Preferred and secondary languages.



---

## ## II. Clinical Observations & Vitals

These handle the "Observation" resource type by joining clinical results with units and status codes.

### ### Entity: **VPR VITAL MEASUREMENT** (#41)

* **Source File:** 120.5 (GMRV VITALS)
* **Logic:** Aggregates data from File #120.5 and the new `OBS` file (#704.117).
* **Transformation:**
* **Value:** Field 1.2 (Measurement).
* **Units:** Mapped to **UCUM** via `C0FHIR VITAL TYPE`.



### ### Entity: **VPR LRCH RESULT** (#17)

* **Source File:** 63.04 (LAB DATA - CHEM)
* **Logic:** Retrieves verified lab results.
* **Mapping Hop:**
* Links File #63 -> File #60 (Lab Test) -> File #64 (WKLD) -> **LOINC**.



---

## ## III. Pharmacy & Medications

Handles the complex join between physician orders and pharmacy fulfillment.

### ### Entity: **VPR MEDICATION** (#56)

* **Source File:** 100 (OR ORDERS)
* **Logic:** Links the order (`OR0`) with the pharmacy package (`ORPK`).
* **Extensions:**
* **VPR DRUG PRODUCT:** Maps to VA Drug Class (#50.605) and Generic (#50.6).
* **VPR DOSAGE STEP:** Captures complex sig (frequency, duration).
* **VPR MED ADMINISTRATION:** Links to BCMA (#53.79) for administration history.



---

## ## IV. Clinical Documents & Encounters

Mapping for the "Encounter" and "Document Reference" resources.

### ### Entity: **VPR VISIT** (#29) / **VPR ADMISSION** (#79)

* **Source File:** 9000010 (VISIT) / 405 (MOVEMENT)
* **Context:** Distinguishes between Inpatient (ASIH) and Ambulatory encounters.
* **Location:** Linked via `VPR LOCATION` (#44).

### ### Entity: **VPR DOCUMENT** (#32)

* **Source File:** 8925 (TIU DOCUMENT)
* **Notes:** Maps Note Text, Signers, and Document Status (Final/Draft).

---

## ## V. Global Technical Logic Summary

These Mumps snippets are the "Engine" inside your entities:

| Transformation Type | Mumps Snippet Example |
| --- | --- |
| **Date Normalization** | `S VALUE=$$DATE^VPRSDA(VALUE)` |
| **Identity Lookup** | `S VALUE=$$GETICN^MPIF001(DIEN)` |
| **Unit Standardization** | `VALUE=$S(VALUE="F":"[degF]",VALUE="lb":"[lb_av]",1:VALUE)` |
| **Provider Lookup** | `S VALUE=$P($G(OR0),U,6)` |

---

### ### Technical Audit Status

The list confirms that entities #267 through #330 are strictly **FHIR Model** enabled, allowing the native VistA DDE engine to process them as JSON objects rather than legacy XML/SDA.

**Would you like me to create a "Mapping Table" for a specific Resource (e.g., just the Patient Identifiers) so you can verify the SSN/MRN formatting against FHIR R4 requirements?**