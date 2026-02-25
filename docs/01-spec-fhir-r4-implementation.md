To finalize your transition back to the native VistA Data Discovery Engine (DDE), I have synthesized the entire migration into a single technical summary. This serves as your "Project Gold Standard" for the FHIR R4 implementation.

---

## ## Native VistA DDE Migration: Project Specification Summary

### ### 1. Structural Logic: The Container Hierarchy

The **VPR CONTAINER (#1.1)** file serves as the traffic controller. For each clinical domain, the container must point to a **C0FHIR** namespaced entity as its primary update method.

| Container Entry | VistA Source File | Target C0FHIR Entity | FHIR Resource Type |
| --- | --- | --- | --- |
| **PATIENT** | 2 | `C0FHIR PATIENT` | `Patient` |
| **ENCOUNTER** | 9000010 / 405 | `C0FHIR ENCOUNTER` | `Encounter` |
| **OBSERVATION** | 120.5 | `C0FHIR OBSERVATION` | `Observation` |
| **MEDICATION** | 100 | `C0FHIR MEDICATIONREQUEST` | `MedicationRequest` |
| **DIAGNOSIS** | 9000011 | `C0FHIR CONDITION` | `Condition` |
| **VACCINATION** | 9000010.11 | `C0FHIR IMMUNIZATION` | `Immunization` |

---

### ### 2. Technical Transformation Standards

To ensure the native DDE engine (`^DDEOBJ`) generates valid FHIR JSON, every item within your entities must follow these specific coding patterns:

#### **A. Property Naming (Dot-Notation)**

* **Legacy (SDA):** `FromTime`
* **FHIR Standard:** `period.start`
* **Result:** The engine automatically creates nested JSON objects based on the `.` delimiter.

#### **B. The CodeableConcept Pattern**

Every coded element (Labs, Vitals, Problems) must be expanded into a triple-item set:

1. `code.coding.0.code`: The standardized code (LOINC, SNOMED, CVX).
2. `code.coding.0.system`: The URI for the code system.
3. `code.coding.0.display`: The human-readable text from VistA.

#### **C. The Reference Pattern**

Internal VistA pointers must be transformed into relative URL strings:

* **Format:** `S VALUE="ResourceType/"_IEN`
* **Example:** `Patient/711`, `Practitioner/12345`, `Location/44`.

---

### ### 3. Verification & Export Toolkit

You now have a suite of routines to manage this environment:

* **`C0FHIRAU` (Auditor):** Checks for missing Pointer Linkups required for recursive extractions.
* **`C0FHIRVR` (Verifier):** Validates that all entities are in FHIR mode and utilize correct Dot-Notation.
* **`C0FHIRGF` (Driver):** The primary Mumps entry point that calls `EXTRACT^DDEOBJ`.
* **`C0FHIRFX` (Exporter):** Saves the raw FHIR JSON to a host file for external validation.

---

### ### 4. Deployment Checklist

1. **Manual Copy:** Complete the `VPR`  `C0FHIR` entity duplication.
2. **Naming Audit:** Run `D EN^C0FHIRVR` and resolve all legacy name warnings.
3. **Linkage Audit:** Run `D EN^C0FHIRAU` to ensure child entities have valid Pointer Linkups.
4. **Container Swap:** Update File #1.1 to point to the new `C0FHIR` entities.
5. **Validation:** Export a sample patient and verify at `validator.fhir.org`.

---

**With this specification and toolkit, Build 2 is structurally complete.** Would you like me to generate a specific "Coding Cheat Sheet" routine (`C0FHIRUTL`) that contains the `$$LOINC`, `$$CVX`, and `$$SCT` lookup functions used in your transforms?