To move strictly to the **FHIR Data Model** using native VistA DDE code, we must analyze the remaining core containers. Since the native engine maps **Item Names** to **JSON keys**, the legacy SDA naming convention in the current VPR entities will produce invalid FHIR resources.

Below is the gap analysis for the remaining top-level containers.

---

## ## 1. ALLERGY (Container #5)

**FHIR Target Resource:** `AllergyIntolerance`

**Analysis:** The legacy VPR Display Name is `Allergy`, which is not a valid FHIR ResourceType. You must duplicate this to ensure the top-level JSON key is correct.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **Allergy** | `code` | Map to a `CodeableConcept` (SCT/RxNorm). |
| **AllergyCategory** | `category` | Map VistA "Drug/Food/Other" to FHIR codes. |
| **Reaction** | `reaction.manifestation` | Nested array for signs/symptoms. |
| **Severity** | `reaction.severity` | Map to "mild", "moderate", "severe". |
| **Status** | `clinicalStatus` | Map to "active", "inactive", "resolved". |
| **EnteredOn** | `recordedDate` | ISO8601 Timestamp. |

---

## ## 2. DIAGNOSIS (Container #8)

**FHIR Target Resource:** `Condition`

**Analysis:** Significant mismatch. VPR uses `Diagnosis`, whereas FHIR uses `Condition`. Furthermore, VPR flattens multiple clinical concepts that FHIR separates.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **Diagnosis** | `code` | Map ICD-10-CM codes to `code.coding`. |
| **DiagnosisType** | `category` | Distinguish between "encounter-diagnosis" and "problem-list-item". |
| **FromTime** | `onsetDateTime` | The date the condition started. |
| **OnsetTime** | `recordedDate` | When the VistA entry was created. |
| **DiagnosingClinician** | `asserter` | Reference to the Practitioner. |

---

## ## 3. MEDICATION (Container #13)

**FHIR Target Resource:** `MedicationRequest`

**Analysis:** In FHIR, "Medication" is usually the name of the substance, while the order itself is a `MedicationRequest`. VPR's structure is too flat for complex FHIR instructions.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **DrugProduct** | `medicationReference` | Link to a separate Medication resource or inline code. |
| **OrderedBy** | `requester` | Must be a Reference object. |
| **EnteredOn** | `authoredOn` | Date the order was signed. |
| **TextInstruction** | `dosageInstruction.text` | The "Sig" or patient instructions. |
| **DosageSteps** | `dosageInstruction` | Complex nesting for dose/route/frequency. |
| **PharmacyStatus** | `status` | Map VistA status to FHIR (active, on-hold, completed). |

---

## ## 4. VACCINATION (Container #14)

**FHIR Target Resource:** `Immunization`

**Analysis:** Close, but FHIR requires specific status reasoning and site/route coding that SDA often bypasses.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **OrderItem** | `vaccineCode` | Map to **CVX** codes. |
| **FromTime** | `occurrenceDateTime` | The actual date/time of administration. |
| **AdministeredAmount** | `doseQuantity.value` | The numeric volume given. |
| **AdministeredUnits** | `doseQuantity.unit` | Use **UCUM** (e.g., `ml`). |
| **LotNumber** | `lotNumber` | Standard string. |

---

## ## 5. OBSERVATION (Container #15)

**FHIR Target Resource:** `Observation`

**Analysis:** This is your strongest candidate for **Reuse**. The Display Names already align well with FHIR. You likely only need to update the M-code transforms for units.

| VPR Item Name (SDA) | FHIR R4 Property Name | Logic / Mapping Requirement |
| --- | --- | --- |
| **ObservationCode** | `code` | Map to **LOINC** codes. |
| **ObservationValue** | `valueQuantity.value` | The measurement value. |
| **ObservationTime** | `effectiveDateTime` | The clinical date of measurement. |

---

### ## Summary Recommendation: "Namespace & Replace"

Because the Native DDE engine is so reliant on the **Item Name** becoming the **JSON Key**, I recommend a "Clean Sweep" of the top-level entities:

1. **Create `C0FHIR` duplicates** for all containers where the **Display Name** or **Item Names** mismatch FHIR specs (Allergy, Diagnosis, Medication, Vaccination).
2. **Redirect the Container File (#1.1):** Update your test environment to use the `C0FHIR` entities as the primary extraction points.
3. **Encapsulate M-Logic:** Move your FileMan-to-ISO-Date and VistA-to-UCUM logic into a common utility like `$$FHIRDT^C0FHIRUTL` so you don't have to rewrite it in every entity's field #1.2.

**Would you like me to generate the specific FileMan `FDA` array to create the `C0FHIR ALLERGYINTOLERANCE` entity with these new property names?**