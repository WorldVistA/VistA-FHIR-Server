these containers are the Entities that are selectable entry points in the Entity file. All of the other VPR entities are embedded in these  
This clarifies the architectural hierarchy perfectly. In the **Data Discovery Engine (DDE)**, the **VPR Containers** act as the **Top-Level Entities**. They are the orchestration layer that the system calls directly, while all the other entities we've been discussing are "nested" or "child" entities that provide the specific data for those containers.

By reformatting your Container list, we can see exactly how VistA views these entry points and which specific "Update Entities" they trigger.

---

## ## VPR Top-Level Container Entry Points

*These are the primary entry points used by the native DDE code to initiate a FHIR or SDA extraction.*

| # | Container (DDE Entry Point) | Source File(s) | Primary Logic Entity | Delete Logic Entity |
| --- | --- | --- | --- | --- |
| **1** | **PATIENT** | 2 | `VPR PATIENT` | - |
| **2** | **ENCOUNTER** | 9000010, 405, 230 | `VPR VISIT` | `VPR VISIT STUB` |
| **5** | **ALLERGY** | 120.8, 120.86 | `VPR ALLERGY` | - |
| **8** | **DIAGNOSIS** | 9000010.07, 45 | `VPR V POV` | `VPR DEL V POV` |
| **9** | **DOCUMENT** | 8925, 74, 63.05 | `VPR DOCUMENT` | `VPR DEL TIU DOCUMENT` |
| **13** | **MEDICATION** | 100 | `VPR MEDICATION` | - |
| **14** | **VACCINATION** | 9000010.11, .23 | `VPR VACCINATION` | `VPR DEL VACCINATION` |
| **15** | **OBSERVATION** | 120.5 | `VPR VITAL MEASUREMENT` | - |
| **17** | **PROCEDURE** | 130, 9000010.18 | `VPR SURGERY` | `VPR DEL V CPT` |

---

### ## Critical Concept: The "Embedded" Hierarchy

Because these containers are the entry points, the switch back to **Native DDE code** depends on how these top-level entities are linked in **File #1.5**.

If you are moving strictly to **FHIR**, your hierarchy for an **Observation** extraction looks like this:

1. **Entry Point:** `OBSERVATION` (The Container/Top Entity)
2. **Embedded logic:** calls `VPR VITAL MEASUREMENT` (The Update Entity)
3. **FHIR Redirect:** If you want FHIR output, you either update Container #15 to point to `C0FHIR VITAL MEASUREMENT`, or you ensure `VPR VITAL MEASUREMENT` is set to **Data Model: FHIR**.

---

### ## Implications for Native DDE Execution

When you call `D EXTRACT^DDEOBJ(CONTAINER, ID, .RES)`, the engine does the following:

* **Step 1:** Looks up the **Container Name** (e.g., "MEDICATION").
* **Step 2:** Identifies the **Update Entity** associated with the **Source File** of the record being processed.
* **Step 3:** Recursively processes all **Embedded Entities** (like `VPR DRUG PRODUCT` or `VPR DOSAGE STEP`) that are defined as items within that Update Entity.

### ### The "Delete" Safety Net

The presence of **Delete Entities** in your container list is vital for the native engine. If the DDE encounters a "Delete" event for a **V POV (#9000010.07)**, it knows to bypass the clinical mapping and jump straight to `VPR DEL V POV` to generate a "Tombstone" record for FHIR/SDA.

**Would you like me to generate a cross-reference list that shows exactly which child entities are "Embedded" within a specific high-level Container, such as DOCUMENT or ENCOUNTER?**