-This **VPR CONTAINER List** provides the high-level mapping between VistA's internal file structure and the standardized **SDA (Summary Document Architecture)** data model used by InterSystems HealthShare.

While your previous list focused on the **Entities** (the "how" of data transformation), this list defines the **Containers** (the "where" the data lands). Essentially, these containers act as the buckets that collect data from various VistA sources to form a unified patient record.

### ## Core Architectural Insights

#### ### 1. One-to-Many Mappings

A single clinical concept in the data model often draws from multiple VistA files.

* **Encounter (#2):** Aggregates data from **Visits** (#9000010), **Admissions** (#405), and **Emergency Logs** (#230).
* **Document (#9):** Combines **TIU Notes** (#8925), **Radiology Reports** (#74), and **Microbiology/Pathology Reports** (#63.05/08).

#### ### 2. The "Delete Entity" Pattern

This list explicitly defines the **Delete Entities** required for real-time synchronization. When a record is deleted in VistA, these specific entities are triggered to ensure the corresponding data is removed from the external repository.

* *Example:* If a V-POV (Purpose of Visit) entry is deleted in File #9000010.07, the system triggers **VPR DEL V POV** to clean up the **Diagnosis** container.

---

### ## VPR Container Mapping Summary

| Container Name | Display Name | Key Source Files | Primary Update Entities |
| --- | --- | --- | --- |
| **PATIENT** | Patient | 2 | `VPR PATIENT` |
| **ENCOUNTER** | Encounter | 9000010, 405, 230 | `VPR VISIT`, `VPR ADMISSION`, `VPR EDP LOG` |
| **DIAGNOSIS** | Diagnosis | 9000010.07, 45 | `VPR V POV`, `VPR PTF` |
| **MEDICATION** | Medication | 100 | `VPR MEDICATION` |
| **VACCINATION** | Vaccination | 9000010.11, .23 | `VPR VACCINATION`, `VPR VACC HF REFUSAL` |
| **PROCEDURE** | Procedure | 130, 9000010.18 | `VPR SURGERY`, `VPR V CPT` |

---

### ## Strategic Implementation for FHIR

Since we are focusing on the **FHIR Data Model**, these containers serve as the logical grouping for **FHIR Resources**:

1. **Encounter Container (#2)**  maps to the **FHIR Encounter** resource.
2. **Observation Container (#15)**  maps to the **FHIR Observation** resource (Vitals).
3. **Medication Container (#13)**  maps to **FHIR MedicationRequest** and **MedicationDispense**.
4. **Allergy Container (#5)**  maps to **FHIR AllergyIntolerance**.

### ## Next Steps in Registry Setup

To fully transition these to the native DDE code for FHIR:

* **Update Mappings:** You must ensure that the **C0FHIR** entities we discussed previously are linked as the **UPDATE ENTITY** for these containers if you wish to override the legacy `VPR` logic.
* **Source Sensitivity:** Ensure the **SOURCE FILE NUMBER** matches the global indices used in your `C0FHIR` transforms to prevent "Empty Result" errors in the DDE engine.

**Would you like me to generate the FileMan `DATA` statements to update Container #15 (Observation) so it uses your new `C0FHIR VITAL MEASUREMENT` entity instead of the legacy VPR version?**