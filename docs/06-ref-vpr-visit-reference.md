# VPR VISIT Reference (for C0FHIR ENCOUNTER)

This document captures the **VPR VISIT** entity structure as a reference for building and maintaining **C0FHIR ENCOUNTER**. VPR VISIT is the legacy SDA-style encounter entity in the VistA Data Discovery Engine (DDE); C0FHIR ENCOUNTER is the FHIR R4 equivalent.

---

## 1. Entity Profile

| Property | VPR VISIT | C0FHIR ENCOUNTER |
|----------|-----------|------------------|
| **Source File** | 9000010 (Visit) | 9000010 |
| **Resource Type** | Encounter | Encounter |
| **Data Model** | SDA / FHIR | FHIR |
| **ID** | Visit IEN | Visit IEN |

---

## 2. Entity-Level Actions (VPR VISIT)

VPR VISIT uses entity-level GET actions stored in `^DDE(EIEN,n)`:

| Subscript | Field | Purpose | Value (typical) |
|-----------|-------|---------|------------------|
| **3** | GET EXIT ACTION | Cleanup after processing | `K ^TMP("PXKENC",$J),VPRVST,VADMVT,VAIP` |
| **4** | GET ID ACTION | Validate/setup per record | `D VST^VPRSDAV` |
| **5** | GET QUERY ROUTINE | Find records to iterate | `QRY^VPRSDAV` |

- **GET EXIT (3):** Clears `^TMP("PXKENC",$J)` and VPR/VADM variables to avoid memory bloat in long sessions.
- **GET ID (4):** `VST^VPRSDAV` sets up visit context (e.g., `VPRVST`) for the current Visit IEN.
- **GET QUERY (5):** `QRY^VPRSDAV` returns visit IDs for a patient when iterating (e.g., by DFN).

**Note:** C0FHIR ENCOUNTER currently does **not** set these entity-level actions in `C0FHIRLE`. If C0FHIRGF or another caller needs to iterate visits by patient or use VPR context, these should be added.

---

## 3. VPR VISIT Items (SDA Names)

From the B index on a typical VPR VISIT entity:

| SDA Item Name | FHIR R4 Equivalent | Notes |
|---------------|--------------------|-------|
| `EncounterNumber` | `identifier.0.value` | Visit IEN |
| `EncounterType` | `class.code` | Map to ActCode (AMB, IMP, EMER) |
| `EncounterCodedType` | `type.0.coding.0.code` | Visit type |
| `FromTime` | `period.start` | ISO8601 |
| `ToTime` | `period.end` | ISO8601 |
| `HealthCareFacility` | `location.0.location` | Reference to Location |
| `ConsultingClinicians` | `participant` | Array of Practitioner refs |
| `EnteredOn` | `meta.lastUpdated` | Audit |
| `EnteredBy` | `meta.lastUpdated` | Audit |
| `EnteredAt` | `meta.lastUpdated` | Audit |
| `Priority` | `priority` | Encounter priority |
| `Extension` | `extension` | Custom extensions |
| `AccountNumber` | `account` | Billing reference |

---

## 4. C0FHIR ENCOUNTER Items (Current)

| FHIR Path | Source | Storage |
|-----------|--------|---------|
| `identifier.0.value` | ID | GET ACTION (6) |
| `identifier.0.system` | Constant | GET ACTION (6) |
| `identifier.0.use` | Constant | GET ACTION (6) |
| `status` | Constant | GET ACTION (6) |
| `class.code` | .07 | OUTPUT TRANSFORM (4) |
| `class.system` | Constant | GET ACTION (6) |
| `type.0.text` | .07 | OUTPUT TRANSFORM (4) |
| `type.0.coding.0.code` | .07 | OUTPUT TRANSFORM (4) |
| `type.0.coding.0.system` | Constant | GET ACTION (6) |
| `subject.reference` | .05 | OUTPUT TRANSFORM (4) |
| `period.start` | .01 | OUTPUT TRANSFORM (4) |
| `period.end` | .18 | OUTPUT TRANSFORM (4) |
| `location.0.location.reference` | .22 | OUTPUT TRANSFORM (4) |
| `location.0.location.display` | .22 | OUTPUT TRANSFORM (4) |
| `serviceProvider.reference` | .21 | OUTPUT TRANSFORM (4) |
| `reasonCode.0.text` | POV 9000010.07 | GET ACTION (6) |
| `length.value` | .01,.18 | GET ACTION (6) |
| `length.unit` | Constant | GET ACTION (6) |
| `id` | ID | GET ACTION (6) |

---

## 5. Gaps vs VPR VISIT

| VPR VISIT | C0FHIR ENCOUNTER | Action |
|-----------|------------------|--------|
| Entity-level GET EXIT (3) | Missing | Add cleanup in C0FHIRLE or C0FHIRGF |
| Entity-level GET ID (4) | Missing | Add `D VST^VPRSDAV` if VPR context needed |
| Entity-level GET QUERY (5) | Missing | Add `QRY^VPRSDAV` for patient-iteration flow |
| `ConsultingClinicians` | No `participant` | Add participant item(s) per 01-spec-encounter.md |
| `EnteredOn` / `EnteredBy` / `EnteredAt` | No meta/audit | Optional; add if audit required |
| `Priority` | Missing | Optional |
| `AccountNumber` | Missing | Optional |
| `Extension` | Missing | Optional |

---

## 6. Key VistA Routines

| Routine | Purpose |
|---------|---------|
| `VST^VPRSDAV` | Sets up visit context for current Visit IEN |
| `VPRV^VPRSDAV(ID)` | Finds providers for visit (participant mapping) |
| `QRY^VPRSDAV` | Returns visit IDs for a patient |
| `DATE^VPRSDA(VALUE)` | Converts FileMan date to ISO8601 |

---

## 7. File #9000010 (Visit) Key Fields

| Field | Description |
|-------|-------------|
| .01 | Visit Date/Time (period.start) |
| .05 | Patient (subject.reference) |
| .07 | Visit Type (class.code, type) |
| .18 | Check-out Date/Time (period.end) |
| .21 | Hospital Location (serviceProvider) |
| .22 | Location (location.reference) |
| 9000010.06 | V-Provider subfile (participant) |
| 9000010.07 | POV subfile (reasonCode) |

---

*Reference compiled from entity registry, 01-spec-encounter*.md, and VPR VISIT B-index dump.*
