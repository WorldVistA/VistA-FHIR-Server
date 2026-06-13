# DDE / Entity File — FHIR Viability Analysis

**Date:** Jun 13, 2026  
**Scope:** Full repository audit of `^DDE`, the Entity file (#1.5 / #1.1), and the C0FHIR suite's ability to produce valid FHIR R4 entries.

---

## Part 1 — Full-Stack Assessment (C0FHIR Suite + ^DDE)

This section evaluates the complete Build 2 pipeline: entity metadata in `^DDE` read by `C0FHIRGF`'s metadata crawler.

### Verdict: No. The current implementation cannot produce a valid FHIR entry.

The following blockers are each independently fatal.

---

### Blocker 1 — Master Loader Is Permanently Disabled

`C0FHIRLD.m` is the routine responsible for populating `^DDE` entity shells. Its entry point
immediately quits:

```
EN ;
Q  ; DO NOT USE DEPRECATED
```

The post-install routine (`C0FHIRPI`) still calls `D EN^C0FHIRLD`. Nothing is ever loaded.
No entity metadata reaches `^DDE` via the Build 2 path.

---

### Blocker 2 — Entity Metadata Is Far Too Sparse

Even if the loader ran, the complete metadata present in source is:

| Entity | Resource Type | Items Defined |
|---|---|---|
| `C0FHIR PATIENT ID` | Patient | **0** (falls back to hard-coded module) |
| `C0FHIR VITAL MEASUREMENT` | Observation | **1** (`valueQuantity.code` only) |
| `C0FHIR LAB RESULT` | Observation | **1** (`code.coding.0.code` only) |

A FHIR R4 Observation requires at minimum `status`, `code`, and `subject` to be present.
A single-item Observation fails even the most basic cardinality check. The `C0FHIR MEDICATION`
entity shell referenced by `C0FHIRL3` is never created.

---

### Blocker 3 — CRAWL Passes Wrong Record Identifier to Clinical Files

`CRAWL` in `C0FHIRGF.m` receives **DFN** (patient file IEN) and passes it unchanged as `ID`
to every entity's FileMan lookup. Vitals records in file 120.5 are keyed by GMRVIEN; lab
results in file 63.04 are keyed by LRDFN. There is no GET ACTION in any item to iterate the
patient-specific record index (`^GMR(120.5,"AA",DFN,...)`) or resolve DFN → LRDFN.
Every `$$GET1^DIQ` call against a clinical file returns null.

---

### Blocker 4 — Required Transform Utilities Are Not Implemented

The vitals item's DATA TRANSFORM (field 1.2) calls:

```
D UCUM^C0FHIRUTL(.VALUE)
```

`UCUM` is not defined anywhere in `src/C0FHIRUTL.m`. The transform XECUTEs, fails silently,
and the only item in the vitals entity returns nothing.

`ISO8601^C0FHIRUTL` is referenced by multiple routines (`C0FHIRPT`, `C0FHIRLM`, `C0FHIRVM`,
`C0FHIRIM`, `C0FHIRPM`, `C0FHIRUT`) but is also absent from `src/C0FHIRUTL.m`. All date
fields across the suite produce unconverted FileMan internal format instead of the ISO8601
strings FHIR requires.

---

### Blocker 5 — Node `^DDE(EIEN,1)` Is Corrupted by Item Loaders

`SHELLS^C0FHIRLD` sets the Data Model flag:

```
S ^DDE(IEN,1)="FHIR"
```

`C0FHIRL1` / `C0FHIRL2` then write the first item into `^DDE(EIEN,1,IIEN,0)`, which in M
overwrites the scalar `"FHIR"` string at node `^DDE(EIEN,1)` with a subfile header
(`^1.51A^...`). The validators `C0FHIRVR` and `C0FHIRAU` check
`$G(^DDE(EIEN,1))="FHIR"` — they will fail on any entity that has items loaded.

---

### Blocker 6 — Aggregator Signature Mismatch Prevents ^DDE Crawler from Being Called

`C0FHIRWS` (the web service entry point) calls:

```
GENFULL^C0FHIRGF(.RTN, DFN, ENCPTR, SDT, EDT)   ; 5 arguments
```

`src/C0FHIRGF.m` defines:

```
GENFULL(RESULT, DFN)   ; 2 arguments
```

The web service is wired to the Build 1 KID version of `C0FHIRGF`, which ignores `^DDE`
entirely and calls hard-coded clinical modules (`C0FHIRLM`, `C0FHIRVM`, etc.). The `^DDE`
metadata crawler is never reached through the normal runtime path.

---

### Additional Structural Issues (Non-Fatal Individually, Compounding)

| Issue | Impact |
|---|---|
| Duplicate routine names (`C0FHIRGF.m`, `C0FHIRGF2.m`, `C0FHIRGF3.m`) | Last-loaded wins; behavior depends on install order |
| `C0FHIRVV` checks `^DDE(EIEN,10,...)` for items; loaders write `^DDE(EIEN,1,...)` | Validator can never find items |
| `LOGERR^C0FHIRGF` called by `C0FHIRWS` and `C0FHIRGF2` but not defined | Runtime error on any error path |
| Item headers missing file/field in pieces 4–5 | `CRAWL`'s `$$GET1^DIQ` branch is never taken; items rely entirely on broken transforms |
| No sub-entity recursion in `CRAWL` | Patient sub-entities (`C0FHIR NAME`, `C0FHIR ADDRESS`, etc.) are silently skipped |
| 0-based vs 1-based array convention mismatch between `C0FHIRGF` and `C0FHIRPT` | May produce structurally inconsistent JSON Bundle |
| Build 1 KID (`dist/`) not updated to Build 2 approach | Shipped product and source are diverged |

---

## Part 2 — Isolated Assessment: Can ^DDE and the Entity File Alone Produce Valid FHIR JSON?

This section sets aside all C0FHIR routines entirely and asks the narrower question:
if the native VistA DDE engine were invoked against the Entity file (File #1.5 / `^DDE`),
could it produce structurally valid FHIR R4 JSON?

### Verdict: No. The Entity file and ^DDE global have three structural properties that make valid FHIR output impossible without an external processor.

---

### Finding 2-1 — The Native DDE Engine Outputs Flat Key-Value JSON; FHIR Requires Deeply Nested Structures

The VistA DDE engine maps each Item's `.01` name directly to a top-level JSON key in the
output object. This is adequate for SDA (Summary Document Architecture), which is mostly flat
XML. FHIR R4 is not flat. Nearly every FHIR resource requires multi-level nesting:

| FHIR R4 Path Required | DDE Output (flat) | Result |
|---|---|---|
| `code.coding[0].system` | `"code"` → scalar value | Invalid — `code` must be a `CodeableConcept` object |
| `subject.reference` | `"subject"` → scalar string | Invalid — `subject` must be a `Reference` object |
| `name[0].given[0]` | `"name"` → scalar string | Invalid — `name` is an array of `HumanName` objects |
| `identifier[0].system` + `.value` | Two separate flat keys | Invalid — `identifier` is an array of `Identifier` objects |

While ITEM TYPE = ENTITY allows nesting by calling sub-entities, the engine still maps
each sub-entity's output as a child object under its own Display Name. This cannot produce
FHIR's required array-of-objects structure for `coding`, `identifier`, `name.given`, etc.
without the sub-entity hierarchy exactly mirroring FHIR's type tree — which the existing
VPR entities do not do.

---

### Finding 2-2 — VPR Item Names Are SDA Names, Not FHIR Property Names

The DDE engine uses the **Item Name (.01)** directly as the JSON key. Every VPR entity uses
SDA vocabulary. The following are representative mismatches against FHIR R4:

| VPR Item Name (SDA) | Required FHIR R4 Property | Entity |
|---|---|---|
| `FromTime` | `effectiveDateTime` | VPR VITAL MEASUREMENT |
| `ObservationValue` | `valueQuantity.value` | VPR LRCH RESULT ITEM |
| `AllergyCategory` | `category` (with FHIR-coded value set) | VPR ALLERGY |
| `Reaction` | `reaction[].manifestation[]` | VPR ALLERGY |
| `DiagnosingClinician` | `asserter` (Reference object) | VPR PROBLEM |
| `EnteredOn` | `recordedDate` | VPR ALLERGY |
| `DrugProduct` | `medicationReference` (Reference object) | VPR MEDICATION |
| `TextInstruction` | `dosageInstruction[].text` | VPR MEDICATION |
| `OrderItem` | `vaccineCode` (CodeableConcept) | VPR VACCINATION |

Using these entities with the DDE engine set to `Data Model = FHIR` would produce JSON
with SDA keys. The output would be syntactically valid JSON but semantically invalid FHIR —
no FHIR validator or client would recognize the properties.

---

### Finding 2-3 — VPR Display Names Do Not Match FHIR R4 ResourceType Values

The DDE engine uses the entity's **Display Name** as the top-level resource identifier.
FHIR R4 requires the field `"resourceType"` to contain an exact R4 type name.
Multiple core VPR entities have Display Names that do not match any FHIR R4 resource:

| VPR Entity | VPR Display Name | Required FHIR ResourceType |
|---|---|---|
| VPR ALLERGY | `Allergy` | `AllergyIntolerance` |
| VPR MEDICATION | `Medication` | `MedicationRequest` |
| VPR VACCINATION | `Vaccination` | `Immunization` |
| VPR PROBLEM | `Diagnosis` | `Condition` |
| VPR DOCUMENT | `Document` | `DocumentReference` |

Even if properties were correctly named, a FHIR Bundle entry with
`"resourceType": "Allergy"` is rejected by every conformant FHIR server.

---

### Finding 2-4 — Data Transforms in Entity Items Produce SDA/VistA-Format Values, Not FHIR-Compliant Values

Entity item field 1.2 (DATA TRANSFORM) contains M code that was written for SDA output:

- **Dates:** `$$DATE^VPRSDA(VALUE)` produces SDA's `YYYYMMDDHHMMSS` format.
  FHIR requires ISO8601 (`YYYY-MM-DDTHH:MM:SS+ZZ:ZZ`).
- **Status codes:** VistA pharmacy status (`dc`, `comp`, `active`) is used directly.
  FHIR `MedicationRequest.status` requires the value set
  `{active, on-hold, cancelled, completed, entered-in-error, stopped, draft, unknown}`.
- **Units:** Raw VistA unit strings (`F`, `lb`, `in`) are passed through.
  FHIR Observation.valueQuantity requires UCUM codes (`[degF]`, `[lb_av]`, `[in_i]`).
- **Code Systems:** Local VistA codes are used without a `system` URI.
  FHIR CodeableConcept requires `coding[].system` to be a full URI
  (e.g., `http://loinc.org`, `http://snomed.info/sct`).

---

### Summary — What the Entity File / ^DDE Actually Is

`^DDE` and File #1.5 are a **metadata registry**, not a FHIR generator. They store:

- Which VistA file and field to read
- What M code to execute before and after the fetch
- What the output key name should be (for SDA)
- Hierarchical relationships between entities (via ITEM TYPE = ENTITY)

This is exactly the right kind of information needed to *drive* a FHIR generator. But the
Entity file itself has no output mechanism — it is inert metadata. The native DDE engine
that consumes this metadata was designed for SDA/XML output, and its flat key-value JSON
mode does not match FHIR's structural requirements.

To produce valid FHIR from `^DDE`, an external processor must:

1. Iterate patient-specific record IENs (not pass DFN to clinical files)
2. Execute GET ACTIONs and DATA TRANSFORMs in proper scope
3. Assemble results into FHIR-shaped nested objects (CodeableConcept, Reference, Quantity, etc.)
4. Recurse into sub-entities and place their output at the correct FHIR array index
5. Apply FHIR-compliant value transforms (ISO8601, UCUM, standard code system URIs)
6. Emit `"resourceType"` with the correct R4 type name
7. Enforce required element presence before emitting an entry

The C0FHIR suite's metadata-crawler design (`C0FHIRGF` + `SETPATH^C0FHIRUTL`) is the
correct architectural response to this. The gap is that the implementation is incomplete,
not that the approach is wrong.

---

## What Would Be Required to Make This Work

| Gap | Required Work |
|---|---|
| `C0FHIRLD` master loader disabled | Re-enable; add complete item sets per resource (15+ items for Patient, 8+ for Observation) |
| Wrong record IDs in CRAWL | GET ACTIONs must iterate patient-record indexes and set `ID` to the correct file IEN |
| `UCUM^C0FHIRUTL` missing | Implement unit conversion table (°F→`[degF]`, lb→`[lb_av]`, in→`[in_i]`, etc.) |
| `ISO8601^C0FHIRUTL` missing | Implement FileMan date → `YYYY-MM-DDTHH:MM:SS+ZZ:ZZ` converter |
| `^DDE(EIEN,1)` node collision | Store Data Model flag in a separate node (e.g., `^DDE(IEN,"MODEL")`) |
| Aggregator signature mismatch | Reconcile `GENFULL^C0FHIRGF` to 2-arg form and update `C0FHIRWS` |
| Sub-entity recursion absent | Extend `CRAWL` to handle ITEM TYPE = ENTITY and place output at correct FHIR path |
| No FHIR required-element check | Add pre-emit validation: reject entries missing `status`, `code`, `subject`, etc. |
| VPR item names (if reusing VPR entities) | Either rename items to FHIR properties or create C0FHIR duplicates with correct names |
| VPR Display Names (if reusing VPR entities) | Update Display Names to exact FHIR R4 ResourceType values |
| SDA data transforms | Replace `$$DATE^VPRSDA` with ISO8601 converter; replace raw codes with FHIR value-set members |
