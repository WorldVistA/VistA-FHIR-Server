# GENFULL Encounter-Centric Design

This document describes the **encounter-centric** architecture of `GENFULL^C0FHIRGF`, the primary RPC for generating FHIR Patient Bundles. The design was restored in Feb 2026 after a refactor had shifted to a patient-centric model.

---

## 1. Overview

`GENFULL` produces a FHIR R4 `Bundle` of type `collection` containing:

1. **Patient** – Demographics from File #2
2. **Encounter(s)** – One or more Encounter resources from File #409.68 (OUTPATIENT ENCOUNTER) / File #9000010 (Visit)
3. **Related clinical resources** – Labs, immunizations, vitals, meds, procedures scoped to each encounter

The bundle is **encounter-driven**: encounters are determined first, then resources linked to those encounters are added.

---

## 2. Signature

```mumps
GENFULL(RESULT,DFN,ENCPTR,SDT,EDT)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `RESULT` | Output (by ref) | Array of JSON lines (XLFJSON format) |
| `DFN` | Input | Patient IEN (File #2) |
| `ENCPTR` | Input | Single encounter IEN (File #409.68), or "" for all/date range |
| `SDT` | Input | Start date (FileMan internal), or "" for no floor |
| `EDT` | Input | End date (FileMan internal), or "" for now |

---

## 3. Operating Modes

| Mode | Call Pattern | Behavior |
|------|--------------|----------|
| **Single encounter** | `GENFULL(.RES,DFN,ENCPTR,"","")` | Process one encounter (File #409.68 IEN) |
| **All encounters** | `GENFULL(.RES,DFN,"","","")` | Process all encounters for the patient |
| **Date range** | `GENFULL(.RES,DFN,"",SDT,EDT)` | Process encounters where date ∈ [SDT, EDT] |

When `ENCPTR` is empty, the routine iterates over `^SCE("ADFN",DFN,CDT)` for encounters in the date window.

---

## 4. Processing Flow

```
GENFULL
  │
  ├─ 1. Initialize Bundle (resourceType=Bundle, type=collection)
  │
  ├─ 2. Get Patient
  │      └─ GETPT^C0FHIRPT(.BNDL,.CNT,DFN)
  │
  ├─ 3. Determine Mode
  │      ├─ If +ENCPTR → PROC(ENCPTR,...)
  │      └─ Else → Loop ^SCE("ADFN",DFN,CDT) for SDT..EDT
  │                 └─ For each CURRENC: PROC(CURRENC,...)
  │
  └─ 4. EXIT: Encode BNDL to JSON, return in RESULT

PROC(IE,BNDL,CNT,DFN,LRDFN)  ; per encounter
  │
  ├─ Get 409.68 data: .01 (date), .05 (Visit IEN)
  │
  ├─ Add Encounter resource
  │      ├─ If C0FHIR ENCOUNTER exists in ^DDE → CRAWL("C0FHIR ENCOUNTER", VISIT)
  │      └─ Else → Minimal stub (id, subject)
  │
  └─ Call clinical modules (encounter-scoped)
         ├─ GETLAB^C0FHIRLM(.BNDL,.CNT,LRDFN,VISIT,ENCID)
         ├─ GETIMM^C0FHIRIM(.BNDL,.CNT,IE,ENCID)
         ├─ GETVIT^C0FHIRVM(.BNDL,.CNT,DFN,VDT,ENCID)
         ├─ GETMEDS^C0FHIRMX(.BNDL,.CNT,DFN,ENCID)
         └─ GETPRC^C0FHIRPM(.BNDL,.CNT,IE,ENCID)
```

---

## 5. Key Data Structures

| Item | Source | Purpose |
|------|--------|---------|
| **ENCPTR** | File #409.68 IEN | Outpatient encounter (SCE) |
| **VISIT** | 409.68.05 | Visit IEN (File #9000010) |
| **ENCID** | `"Encounter-"_VISIT` | FHIR Encounter reference id |
| **^SCE("ADFN",DFN,CDT,CURRENC)** | VistA index | Encounters by patient and date |

---

## 6. CRAWL and DDE Integration

When the **C0FHIR ENCOUNTER** entity exists in `^DDE`, `PROC` uses `CRAWL` to build the Encounter resource from DDE metadata:

- Reads items from `^DDE(EIEN,1,...)` (GET ACTION field 6, OUTPUT TRANSFORM field 4)
- Produces full FHIR Encounter (identifier, class, type, period, location, etc.)

If the entity does not exist, a minimal Encounter stub is added (id, subject only).

---

## 7. Clinical Modules

| Module | Routine | Key Params | Source |
|--------|---------|------------|--------|
| Labs | `GETLAB^C0FHIRLM` | LRDFN, VISIT, ENCID | File #63 (LR CH) |
| Immunizations | `GETIMM^C0FHIRIM` | ENCPTR, ENCID | File #9000010.11 |
| Vitals | `GETVIT^C0FHIRVM` | DFN, VDT, ENCID | File #120.5 |
| Meds | `GETMEDS^C0FHIRMX` | DFN, ENCID | File #52 |
| Procedures | `GETPRC^C0FHIRPM` | ENCPTR, ENCID | File #9000010.18 |

Each module adds resources with `encounter.reference = "Encounter/"_ENCID`.

---

## 8. Callers

| Caller | Invocation | Notes |
|--------|------------|------|
| **C0FHIRWS** | `GENFULL(.RTN,DFN,ENCPTR,SDT,EDT)` | Web service; FILTER provides dfn, encounter, sdt, edt |
| **C0FHIRTS** | `GENFULL(.RES,DFN)` | Test; all encounters (ENCPTR/SDT/EDT empty) |
| **C0FHIRFX** | `GENFULL(.RESULT,DFN)` | File export; all encounters |
| **C0FHIRUT** | `GENFULL(.RES,DFN,"","","")` | All encounters |
| **C0FHIRTS2** | `GENFULL(.RTN,DFN,ENCPTR,SDT,EDT)` | Full params |

---

## 9. Error Handling

- **LOGERR(MSG,ERR,BNDL,CNT)** – Logs FileMan errors as FHIR OperationOutcome
- **LOGERR2(MSG,DIAG,BNDL,CNT)** – Logs custom diagnostics (e.g. "Missing DFN or Name")

---

## 10. Related Documents

- [01-spec-encounter.md](01-spec-encounter.md) – C0FHIR ENCOUNTER entity spec
- [06-ref-vpr-visit-reference.md](06-ref-vpr-visit-reference.md) – VPR VISIT reference
- [03-impl-C0FHIR_Implementation_Guide.md](03-impl-C0FHIR_Implementation_Guide.md) – Implementation guide

---

*Document generated Feb 2026. Reflects C0FHIRGF Build 3 (encounter-centric restoration).*
