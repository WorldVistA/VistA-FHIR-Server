I would like to know if we need to make duplicate FHIR data model Entities or whether we can user the VPR Entities. Please analyze the Display Names and compare them to the FHIR spec

To answer whether you need to duplicate entities or can reuse the VPR ones, we have to look at the **Display Name** property. In the VistA Data Discovery Engine (DDE), the **Display Name** is the key that defines the output tag (for XML/SDA) or the resource/property name (for FHIR).

If the **Display Name** in your VPR entities aligns with **FHIR R4 Resource names**, you can reuse them by simply changing the **Data Model** field to `FHIR`. If the names are SDA-specific, you must duplicate them to avoid breaking legacy integrations.

---

### ## Display Name Analysis: VPR vs. FHIR R4

| VPR Container Name | VPR Display Name | FHIR R4 Resource Name | Alignment | Recommendation |
| --- | --- | --- | --- | --- |
| **PATIENT** | `Patient` | `Patient` | **Match** | **Reuse** |
| **ENCOUNTER** | `Encounter` | `Encounter` | **Match** | **Reuse** |
| **ALLERGY** | `Allergy` | `AllergyIntolerance` | **Mismatch** | **Duplicate** |
| **OBSERVATION** | `Observation` | `Observation` | **Match** | **Reuse** |
| **MEDICATION** | `Medication` | `MedicationRequest` | **Mismatch** | **Duplicate** |
| **VACCINATION** | `Vaccination` | `Immunization` | **Mismatch** | **Duplicate** |
| **DIAGNOSIS** | `Diagnosis` | `Condition` | **Mismatch** | **Duplicate** |
| **DOCUMENT** | `Document` | `DocumentReference` | **Mismatch** | **Duplicate** |
| **PROCEDURE** | `Procedure` | `Procedure` | **Match** | **Reuse** |

---

### ## Detailed Structural Obstacles

#### 1. The "Resource Name" Problem

The native DDE engine uses the **Entity Display Name** as the top-level JSON key when the model is set to FHIR.

* **VPR ALLERGY (#5):** Using this for FHIR will output a JSON object starting with `"Allergy": {...}`. FHIR R4 strictly requires the resource type to be `"resourceType": "AllergyIntolerance"`.
* **Verdict:** You need a new `C0FHIR ALLERGY` entity where the Display Name is `AllergyIntolerance`.

#### 2. Property Name Collisions

Inside the entities, VPR uses "SDA-speak" for item names.

* **Example (VPR V POV #88):** Uses `OnsetTime`.
* **FHIR Spec:** Uses `recordedDate` or `onsetDateTime`.
* **Native DDE Impact:** The native engine maps the **Item Name** directly to the JSON key. If you reuse the VPR items, your FHIR output will contain non-standard keys like `FromTime` instead of `effectiveDateTime`.

#### 3. Data Transformation Logic

FHIR often requires a different "shape" of data than SDA:

* **Reference Strings:** VPR/SDA often wants a flat UID. FHIR requires a Reference object (e.g., `{"reference": "Patient/123"}`).
* **Coding Systems:** VPR/SDA might use `SDA Code Table`. FHIR requires a `CodeableConcept` with specific `system` and `code` URI keys.

---

### ## Final Recommendation: The "Hybrid" Approach

You do **not** need to duplicate every single entity, but you should duplicate the **Top-Level Containers**.

1. **Duplicate the Entry Points:** Create new entities for `C0FHIR ALLERGYINTOLERANCE` and `C0FHIR CONDITION`. This allows you to set the **Display Name** to exactly what the FHIR spec requires.
2. **Reuse "Leaf" Entities:** You can reuse lower-level "leaf" entities like `VPR FACILITY` or `VPR USER` **IF** their display names are generic (e.g., `Organization`, `Practitioner`) and you update their internal items to handle FHIR `CodeableConcept` logic via Mumps transforms.
3. **Namespace Isolation:** To maintain the 8:00 PM demo's stability, keep the `C0FHIR` namespace for the top-level objects. This ensures that a change to support a FHIR requirement doesn't accidentally break a legacy HealthShare SDA feed.

**Would you like me to generate a list of the specific "Item Name" changes required for the ENCOUNTER entity to move it from SDA Display Names to valid FHIR R4 Property names?**