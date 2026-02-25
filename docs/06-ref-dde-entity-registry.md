To make this extensive **ENTITY List** scannable and useful for documentation, I have organized the raw text into a structured technical reference. I've categorized the entities by clinical domain and summarized their key mapping logic.

---

## ## VistA Data Discovery Engine (DDE) Entity Registry

**Report Date:** Feb 21, 2026

**Namespace Coverage:** `VPR` (Legacy/SDA) and `C0FHIR` (Modern/FHIR)

---

### ### 1. Administrative & Patient Core

These entities handle the fundamental "Identity" layer of the patient record, primarily leveraging the **File #2 (PATIENT)** global and **VADPT** APIs.

| Entity | File # | Primary Logic / Notes |
| --- | --- | --- |
| **VPR PATIENT ID** (#1) | 2 | Maps SSN, MRN, and ICN using `$$GETICN^MPIF001`. |
| **VPR PATIENT** (#20) | 2 | Full demographic suite (Name, DOB, Gender, Religion). |
| **C0FHIR PATIENT** (#267) | 2 | FHIR-native mapping of demographics and identifiers. |
| **VPR NAME** (#6) | N/A | Parsing utility using Kernel's `NAMECOMP^XLFNAME`. |
| **VPR FACILITY** (#7) | 4 | Maps Station Numbers using `$$STA^XUAF4`. |

---

### ### 2. Clinical Observations & Vitals

Handles the high-volume transactional data from Vitals and Laboratory results.

* **Vitals Mapping (#41, #42):**
* **Source:** File #120.5 and #704.117.
* **Normalization:** Transforms units (F, lb, in) to **UCUM** standards (e.g., `[degF]`).


* **Lab Results (#17, #18, #12):**
* **Source:** File #63.04 (Chem) and File #60 (Lab Test).
* **Standardization:** Links local results to **LOINC** via the WKLD code hop.


* **C0FHIR Alternatives:** See Entities **#268-269** for the FHIR-optimized versions of these clinical paths.

---

### ### 3. Medications & Orders

Complex multi-file joins between the **Orders (#100)**, **Pharmacy (#52/#55)**, and **Medication Administration (#53.79)** files.

* **VPR MEDICATION (#56):** * **Joins:** Pulls Placer info from #100 and Pharmacy data from #52.
* **Transforms:** Converts local status codes (dc, active) to SDA/FHIR equivalents.


* **VPR IV PRODUCT (#94):** * Supports complex IV additive/solution strings (e.g., `ien^name^amount^type`).
* **PSO Activity Log (#245):** * Detailed tracking of prescription status changes and pharmacy activity.

---

### ### 4. Clinical Documents & Radiology

Mappings for **TIU (#8925)** and **Radiology (#74/#70)**.

* **VPR DOCUMENT (#32):** Pulls note text and status from TIU.
* **VPR RAD RESULT (#37, #89):** * Links Radiology orders to reports in File #74.
* **Extension:** Identifies if images are present via File #2005.



---

### ### 5. Health Factors & History

Manages the "Social History" and "Problem List" data.

* **VPR PROBLEM (#11):** Maps Problems (#9000011) to **SNOMED CT** codes.
* **VPR SOCIAL HISTORY (#47):** Specifically filters Health Factors for tobacco use and social habits.
* **VPR PREGNANCY (#85):** Tracks current pregnancy status from File #790.05.

---

### ### Technical Transformations Summary

The list reveals several recurring **Mumps snippets** used across the registry:

* **Date Normalization:** `S VALUE=$$DATE^VPRSDA(VALUE)` (Converts FileMan to ISO/SDA).
* **Provider Attribution:** `S VALUE=$P(OR0,U,6)` (Standardized pointer extraction).
* **Entity Nesting:** The list shows extensive use of **ITEM TYPE: ENTITY**, allowing the engine to recursively build a "Patient Bundle" by calling sub-entities.

---

### ## Registry Integrity Status

> **Architecture Note:** The transition from the `VPR` namespace to `C0FHIR` (Entities #267+) indicates a shift from **Summary Document Architecture (SDA)** to **FHIR R4**. This allows your system to support legacy HealthShare integrations while simultaneously serving modern API consumers.

**Would you like me to extract a specific subset of these—for example, just the `GET ACTION` code for all Pharmacy-related entities—to help with your routine debugging?**