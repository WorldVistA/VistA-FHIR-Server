This specification outlines the manual migration of your **VPR (SDA)** entities into **C0FHIR (FHIR R4)** entities. Since the native VistA DDE engine uses the **Item Name** as the JSON key, renaming these fields is the most critical step for R4 compliance.

---

## ## Migration Strategy: "Copy & Refactor"

For each container, you will:

1. **Duplicate** the VPR Entity into a new `C0FHIR` namespace entry.
2. **Update Display Name** to the exact FHIR Resource type.
3. **Rename Items** to match FHIR R4 property paths.
4. **Inject Logic** for `CodeableConcept` and `Reference` structures.

---

## ## 1. ENCOUNTER (Container #2)

**New Entity Name:** `C0FHIR ENCOUNTER`

**Display Name:** `Encounter`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| EncounterNumber | `identifier.0.value` | Wrap internal IEN in an Identifier object. |
| EncounterType | `class.code` | Map to ActCode (e.g., `AMB`, `IMP`). |
| EncounterCodedType | `type.0.coding.0.code` | Map local visit type to CPT/SNOMED. |
| FromTime | `period.start` | `S VALUE=$$DATE^VPRSDA(VALUE)` |
| ToTime | `period.end` | `S VALUE=$$DATE^VPRSDA(VALUE)` |
| HealthCareFacility | `location.0.location` | Must return a Reference: `location/IEN`. |
| Status | `status` | Map VistA status to FHIR (e.g., `finished`). |

---

## ## 2. ALLERGY (Container #5)

**New Entity Name:** `C0FHIR ALLERGYINTOLERANCE`

**Display Name:** `AllergyIntolerance`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| Allergy | `code.coding.0.code` | Map GMR Allergy to RxNorm or SNOMED. |
| AllergyCategory | `category.0` | Map VistA set of codes to FHIR categories. |
| Reaction | `reaction.0.substance` | Map to the manifesting substance. |
| Severity | `reaction.0.severity` | Normalize to `mild`, `moderate`, `severe`. |
| Status | `clinicalStatus.coding.0.code` | Map to `active` or `resolved`. |
| EnteredOn | `recordedDate` | Use ISO8601 Timestamp. |

---

## ## 3. DIAGNOSIS (Container #8)

**New Entity Name:** `C0FHIR CONDITION`

**Display Name:** `Condition`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| Diagnosis | `code.coding.0.code` | Map ICD-10 to `Condition.code`. |
| DiagnosisType | `category.0.coding.0.code` | Set to `encounter-diagnosis` or `problem-list-item`. |
| FromTime | `onsetDateTime` | Date condition was first noted. |
| Status | `clinicalStatus.coding.0.code` | Map FileMan status to FHIR. |
| OnsetTime | `recordedDate` | The date the record was entered in VistA. |

---

## ## 4. MEDICATION (Container #13)

**New Entity Name:** `C0FHIR MEDICATIONREQUEST`

**Display Name:** `MedicationRequest`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| DrugProduct | `medicationCodeableConcept.coding.0.code` | Map local drug to RxNorm. |
| OrderedBy | `requester` | Return Practitioner Reference: `Practitioner/IEN`. |
| EnteredOn | `authoredOn` | Signature date in ISO8601. |
| TextInstruction | `dosageInstruction.0.text` | Full Sig text. |
| DosageSteps | `dosageInstruction.0.doseAndRate.0.doseQuantity.value` | Use numeric value only. |
| PharmacyStatus | `status` | Map to `active`, `completed`, `on-hold`. |

---

## ## 5. OBSERVATION (Container #15)

**New Entity Name:** `C0FHIR OBSERVATION`

**Display Name:** `Observation`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| ObservationCode | `code.coding.0.code` | Map Vital Type to **LOINC**. |
| ObservationValue | `valueQuantity.value` | Ensure numeric only (no units in string). |
| ObservationTime | `effectiveDateTime` | Clinical measurement time. |
| Units | `valueQuantity.unit` | Use **UCUM** strings (e.g., `[lb_av]`). |

---

## ## 6. VACCINATION (Container #14)

**New Entity Name:** `C0FHIR IMMUNIZATION`

**Display Name:** `Immunization`

| VPR Item Name (SDA) | **New FHIR Item Name** | M-Transform / Logic Change |
| --- | --- | --- |
| OrderItem | `vaccineCode.coding.0.code` | Map local VistA Immunization to **CVX**. |
| FromTime | `occurrenceDateTime` | Admin date/time. |
| LotNumber | `lotNumber` | Direct string mapping. |
| Status | `status` | Usually `completed` or `not-done`. |

---

### ## Implementation Note: Object Nesting

Because the native DDE engine creates a JSON object for every **Item Type: ENTITY**, you should ensure your "Leaf" entities (like **C0FHIR NAME**) use child items like `family` and `given` rather than the VPR legacy names `FamilyName` and `GivenName`.

**Would you like me to provide the specific M-code for the `CodeableConcept` transform that you'll need to paste into the `code.coding.0` fields?**