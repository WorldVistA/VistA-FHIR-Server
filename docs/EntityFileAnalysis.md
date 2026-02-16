This **ENTITY List** provides the mapping metadata required to bridge VistA's M-based globals to the **FHIR R4 resources** we are building in **Build 2**.

Below is the dense categorization of these entities into FHIR resources, aligned with your current **C0FHIR Suite** architecture. I have flagged critical "Get Actions" and field numbers that must be respected in your M routines to ensure data integrity.

---

### 1. Administrative & Identification Resources

These entities map primarily to the `Patient`, `Practitioner`, and `Location` FHIR resources.

| ENTITY Name | VistA File | FHIR R4 Resource | Key Mapping Logic |
| --- | --- | --- | --- |
| **VPR PATIENT** | `2` | `Patient` | Uses `VADPT`. Note **Item 15 (Races)** and **Item 16 (EthnicGroup)**—essential for US Core compliance. |
| **VPR PATIENT ID** | `2` | `Patient.identifier` | Maps SSN (2,.09), MRN, and ICN. Crucial for cross-site patient matching. |
| **VPR PROVIDER** | `200` | `Practitioner` | Pulls Name (200,.01), Work Phone (.132), and Email (.151). |
| **VPR LOCATION** | `44` | `Location` | Maps Clinic Name (44,.01) and Organization link (Field 3). |
| **VPR FACILITY** | `4` | `Organization` | Uses `$$STA^XUAF4` to retrieve the Station Number (Field 99). |

---

### 2. Clinical Observations & Measurements

These represent the "payload" of your FHIR Bundle.

| ENTITY Name | VistA File | FHIR R4 Resource | Key Mapping Logic |
| --- | --- | --- | --- |
| **VPR VITAL MEASUREMENT** | `120.5` | `Observation` | **Item 8 (Code)** maps to LOINC via VPR VITAL TYPE. **Item 9 (Value)** pulls from 1.2. |
| **VPR LRCH RESULT ITEM** | `63.04` | `Observation` | Traverses Lab Data. Note **Item 18 (ObservationTime)** uses `9999999-$P(IEN,",",2)` for reverse dates. |
| **VPR HEALTH CONCERN** | `9000010.23` | `Observation` | Uses Health Factors. **Item 11 (Status)** maps to social history/concerns. |
| **VPR SOCIAL HISTORY** | `9000010.23` | `Observation` | Specifically filters for tobacco/habit factors. |

---

### 3. Medications & Orders

These entities bridge the Pharmacy and OE/RR (Orders) packages to FHIR.

| ENTITY Name | VistA File | FHIR R4 Resource | Key Mapping Logic |
| --- | --- | --- | --- |
| **VPR MEDICATION** | `100 / 52` | `MedicationRequest` | **Item 15 (Status)** uses Output Transform to convert VistA status (dc, comp) to FHIR (cancelled, active). |
| **VPR DRUG PRODUCT** | `50` | `Medication` | **Item 22 (Generic)** links to File #50.6. Maps to RxNorm in your `C0FHIRRX` routine. |
| **VPR LAB ORDER** | `100` | `ServiceRequest` | Tracks the "placer" side of the lab request. |

---

### 4. Clinical Activity & Records

Encounters and Documents that provide the context for clinical data.

| ENTITY Name | VistA File | FHIR R4 Resource | Key Mapping Logic |
| --- | --- | --- | --- |
| **VPR VISIT** | `9000010` | `Encounter` | **Item 5 (Type)** transform: `VALUE=$S(VALUE:"I",VALUE=0:"O",1:VALUE)` (Inpatient/Outpatient). |
| **VPR DOCUMENT** | `8925` | `DocumentReference` | **Item 7 (NoteText)** uses `D TEXT^VPRSDAT` to pull the TIU word-processing global. |
| **VPR ADMISSION** | `405` | `Encounter` | Extends the visit with ward/room/bed data from Patient Movement. |
| **VPR PROBLEM** | `9000011` | `Condition` | **Item 9 (Status)** transform: `A` -> `Active`, `I` -> `Inactive`. Maps to SNOMED CT. |

---

### 5. Specialized Clinical Domains

Safety, history, and specialized procedures.

| ENTITY Name | VistA File | FHIR R4 Resource | Key Mapping Logic |
| --- | --- | --- | --- |
| **VPR ALLERGY** | `120.8` | `AllergyIntolerance` | **Item 8 (Certainty)** maps to FHIR `Confirmed` status. |
| **VPR VACCINATION** | `9000010.11` | `Immunization` | Uses `VIMM^PXPXRM`. **Item 35 (OrderItem)** maps to CVX codes. |
| **VPR SURGERY** | `130` | `Procedure` | Pulls from the Surgical package (#130). Note **Item 4 (EncounterNumber)** link to Visit. |

---

## ## Technical Integration for Build 2

To use this report in your **Build 2** routines, you must focus on the **"GET ACTION"** logic provided in the ENTITY list:

1. **Date Consistency:** The ENTITY list frequently uses `$$DATE^VPRSDA`. In your `C0FHIRUTL`, ensure this function correctly handles both the FileMan internal format and the required FHIR ISO8601 output.
2. **Referential Integrity:** Entity **#29 (VPR VISIT)** uses the `^TMP("PXKENC",$J)` global. Ensure your aggregator (`C0FHIRGF`) cleans this up to prevent memory bloat in long patient sessions.
3. **Reverse Date Logic:** For Vitals and Labs (Entities **#41** and **#18**), your M code must calculate the reverse date correctly: `S VALUE=9999999-DATE`.

### Next Step

Would you like me to generate the **M-code for a "Validation Routine"** that checks your `^DDE` (Entity) file entries against this list to ensure no parameters were missed during the Build 2 update?