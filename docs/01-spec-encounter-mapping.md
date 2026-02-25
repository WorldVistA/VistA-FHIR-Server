To move from **VPR (SDA)** to **C0FHIR (FHIR R4)** using the native VistA DDE engine, you need to align the **Item Names** in your entities with the specific property names defined in the FHIR specification.

The native DDE engine uses the **Item Name** as the JSON key. If the Item Name is `FromTime`, your JSON will be `"FromTime": "..."`, which will fail FHIR validation.

Here is the conversion outline for the **ENCOUNTER** container.

---

## ## Encounter Mapping: SDA vs. FHIR R4

The **Encounter (#2)** container draws from three main VistA sources: **Visit (#9000010)**, **Admission (#405)**, and **EDP Log (#230)**. To make this FHIR-compliant, you must rename the items within the entities.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **EncounterNumber** | `identifier` | Map as an Identifier array (VistA Visit IEN). |
| **EncounterType** | `class` | Map to FHIR ActCode (AMB, IMP, EMER, etc.). |
| **EncounterCodedType** | `type` | Map to SNOMED or CPT codes for the visit type. |
| **FromTime** | `period.start` | Use the ISO8601 date format. |
| **ToTime** | `period.end` | Use the ISO8601 date format. |
| **HealthCareFacility** | `location.location` | Map as a Reference to the Location resource. |
| **ConsultingClinicians** | `participant` | Map as an array of Practitioner references. |
| **Status** | `status` | Map VistA status (active, finished, cancelled). |
| **AdmitReason** | `reasonCode` | Map the primary reason for admission. |

---

### ## Strategic Implementation: The Duplicate Entity Plan

Because of the differences in naming and structure, you should **duplicate** the top-level entities into the `C0FHIR` namespace. This allows you to point the native DDE at a FHIR-perfect definition without corrupting the existing SDA feed.

#### ### New FHIR Top-Level Entities Required:

1. **C0FHIR ENCOUNTER:**
* **Display Name:** `Encounter` (Matches FHIR Resource).
* **Items:** Rename `FromTime`  `period.start`.


2. **C0FHIR CONDITION:**
* **Display Name:** `Condition` (Replaces VPR `Diagnosis`).
* **Items:** Rename `OnsetTime`  `onsetDateTime`.


3. **C0FHIR ALLERGYINTOLERANCE:**
* **Display Name:** `AllergyIntolerance` (Replaces VPR `Allergy`).
* **Items:** Structure as `code.coding` rather than a flat string.


4. **C0FHIR MEDICATIONREQUEST:**
* **Display Name:** `MedicationRequest` (Replaces VPR `Medication`).
* **Items:** Rename `OrderedBy`  `requester`.



---

### ## Technical Step: Updating the Container File

Once these new entities are created, you will need to update the **VPR CONTAINER (#1.1)** file to point to these new "Update Entities" when the system is in FHIR mode.

**Example Update Logic:**

> If `SOURCE FILE` = 405 (Admission), use `UPDATE ENTITY` = **C0FHIR ADMISSION**.

### ### Why reuse "Leaf" Entities?

You can still reuse entities like **VPR USER** or **VPR LOCATION** if you wrap them in a FHIR-compliant property name in the parent.

* *Example:* In `C0FHIR ENCOUNTER`, you create an item named `location` and point it to the entity `VPR LOCATION`. The JSON will correctly nest the facility data under the `"location": { ... }` key.

**Would you like me to generate the FileMan code to create the new `C0FHIR ENCOUNTER` items so they correctly use the FHIR `period.start` and `participant` naming conventions?**