# ^DDE and the Entity File — Standalone FHIR Capability Assessment

**Date:** Jun 13, 2026  
**Scope:** Can the VistA Data Discovery Engine global (`^DDE`) and File #1.5 (Entity File),
operating without any C0FHIR routines, produce structurally valid FHIR R4 JSON entries?

**Verdict: No.**

---

## What ^DDE and the Entity File Actually Are

`^DDE` is the M global backing File #1.5, the VistA Data Discovery Engine (DDE) Entity
registry. Each entity record stores:

- **Default File (.02):** The VistA FileMan file number that is the primary data source
- **Display Name (.03):** The label used as the output resource identifier
- **Resource Type (.04):** Target output type
- **Data Model (.05 / node 1):** Flag (`FHIR` or `SDA`) controlling output format
- **Item subfile (#1.51):** One record per output field, containing:
  - **Item Name (.01):** The key written into the output object
  - **Sequence (.02):** Ordering
  - **Source File (.04) / Source Field (.05):** FileMan lookup coordinates
  - **GET ACTION (1.1):** M code executed before the fetch to set up context
  - **DATA TRANSFORM (1.2):** M code executed after the fetch to shape `VALUE`

This is the correct kind of information to drive a FHIR generator. The Entity file is,
however, inert metadata — it has no output mechanism of its own. The VistA DDE engine
(`EN^DDE` / `EXTRACT^DDEOBJ`) consumes this metadata, but that engine was designed for
SDA/XML output. Its JSON mode has structural limitations that make valid FHIR R4 output
impossible for the following reasons.

---

## Finding 1 — The Native DDE Engine Produces Flat Key-Value JSON; FHIR R4 Requires Deep Nesting

The DDE engine maps each Item Name (field .01) directly to a JSON key in the output object.
One item produces one key-value pair. This model is adequate for SDA, which is largely flat
XML. FHIR R4 is not flat: nearly every resource requires multi-level objects and
arrays-of-objects.

Representative examples of the mismatch:

| FHIR R4 Requires | DDE Flat Output | Why It Fails |
|---|---|---|
| `"code": {"coding": [{"system": "http://loinc.org", "code": "8867-4"}]}` | `"code": "8867-4"` | `code` must be a `CodeableConcept` object, not a scalar |
| `"subject": {"reference": "Patient/12345"}` | `"subject": "12345"` | `subject` must be a `Reference` object |
| `"name": [{"family": "SMITH", "given": ["JOHN"]}]` | `"name": "SMITH,JOHN"` | `name` is an array of `HumanName` objects |
| `"identifier": [{"system": "...", "value": "..."}]` | `"identifier": "..."` | `identifier` is an array of `Identifier` objects |
| `"valueQuantity": {"value": 98.6, "unit": "[degF]", "system": "http://unitsofmeasure.org"}` | `"valueQuantity": "98.6"` | `valueQuantity` must be a `Quantity` object |

ITEM TYPE = ENTITY allows the engine to nest a child entity's output under its parent's
key, which enables one level of object nesting. However, this cannot produce:

- **Arrays of objects** at known indexes (e.g., `coding[0]`, `identifier[1]`, `given[0]`)
- **Sibling keys inside the same nested object** emitted by different items
  (e.g., `coding[0].system` and `coding[0].code` must land in the same array slot)
- **Parallel sub-arrays** within a single resource entry

The ITEM TYPE = ENTITY mechanism would require a sub-entity hierarchy that exactly mirrors
FHIR's type tree (one sub-entity per `CodeableConcept`, per `Reference`, per `Quantity`,
per `HumanName`, etc.) and the DDE engine would need to respect array indexing — neither
of which is present in the existing VPR entity definitions.

---

## Finding 2 — VPR Item Names Are SDA Vocabulary, Not FHIR R4 Property Names

The DDE engine writes the Item Name (field .01) verbatim as the JSON key. All existing
VPR entities use Summary Document Architecture (SDA) naming conventions, which were
designed for InterSystems HealthShare XML output. These names do not correspond to any
valid FHIR R4 property path.

Representative item name mismatches:

| VPR Entity | VPR Item Name (SDA) | Required FHIR R4 Property |
|---|---|---|
| VPR VITAL MEASUREMENT | `FromTime` | `effectiveDateTime` |
| VPR VITAL MEASUREMENT | `ObservationValue` | `valueQuantity.value` |
| VPR ALLERGY | `AllergyCategory` | `category` |
| VPR ALLERGY | `Reaction` | `reaction[].manifestation[]` |
| VPR ALLERGY | `EnteredOn` | `recordedDate` |
| VPR PROBLEM | `DiagnosingClinician` | `asserter` |
| VPR PROBLEM | `OnsetTime` | `onsetDateTime` |
| VPR MEDICATION | `DrugProduct` | `medicationReference` |
| VPR MEDICATION | `TextInstruction` | `dosageInstruction[].text` |
| VPR VACCINATION | `OrderItem` | `vaccineCode` |
| VPR VACCINATION | `AdministeredAmount` | `doseQuantity.value` |
| VPR VISIT | `EncounterType` | `class` (with FHIR ActCode value set) |
| VPR DOCUMENT | `NoteText` | `content[].attachment.data` |

Output produced by native DDE execution against these entities, even with `Data Model = FHIR`,
would be syntactically valid JSON but semantically unrecognizable to any FHIR server,
validator, or client. No FHIR conformance claim could be made.

---

## Finding 3 — VPR Display Names Do Not Match Legal FHIR R4 `resourceType` Values

FHIR R4 requires every resource entry to contain `"resourceType"` set to a value from the
normative resource type list. The DDE engine uses the entity's **Display Name** as the
top-level resource identifier. Several core VPR entities carry Display Names that are not
valid FHIR R4 resource types:

| VPR Entity | VPR Display Name | Required FHIR R4 `resourceType` |
|---|---|---|
| VPR ALLERGY | `Allergy` | `AllergyIntolerance` |
| VPR MEDICATION | `Medication` | `MedicationRequest` |
| VPR VACCINATION | `Vaccination` | `Immunization` |
| VPR PROBLEM | `Diagnosis` | `Condition` |
| VPR DOCUMENT | `Document` | `DocumentReference` |
| VPR ADMISSION | `Admission` | `Encounter` |

A FHIR Bundle entry containing `"resourceType": "Allergy"` is rejected by every conformant
FHIR server regardless of the quality of the remaining content. The `resourceType` value
is the primary dispatch key used by FHIR servers to route, validate, and store resources.
An unrecognized value is a hard failure.

Note: `Patient`, `Encounter`, `Observation`, and `Procedure` do align between VPR Display
Names and FHIR R4 — these four could produce entries with a valid `resourceType` value if
the other findings were also resolved.

---

## Finding 4 — Entity DATA TRANSFORMs Produce SDA-Format Values, Not FHIR-Compliant Values

The M code stored in Item field 1.2 (DATA TRANSFORM) was written for SDA output.
The value formats it produces are incompatible with FHIR R4 data type requirements:

### Dates

- **Entity transform:** `S VALUE=$$DATE^VPRSDA(VALUE)`
- **Output format:** `YYYYMMDDHHMMSS` (SDA internal format)
- **FHIR R4 requirement:** ISO8601 with timezone offset — `YYYY-MM-DDTHH:MM:SS+ZZ:ZZ`
- **Impact:** Every date/time element (`effectiveDateTime`, `recordedDate`, `authoredOn`,
  `occurrenceDateTime`, etc.) would fail FHIR date type validation.

### Status Codes

- **Entity transform:** Pass-through of VistA pharmacy status strings
- **Output examples:** `dc`, `comp`, `hold`, `pnd`
- **FHIR R4 requirement:** Bound value sets, e.g., `MedicationRequest.status` must be one of
  `{active, on-hold, cancelled, completed, entered-in-error, stopped, draft, unknown}`
- **Impact:** Every status field would fail value-set binding validation.

### Units of Measure

- **Entity transform:** Raw VistA unit labels or no transform
- **Output examples:** `F`, `lb`, `in`, `mmHg`, `kg`
- **FHIR R4 requirement:** `Observation.valueQuantity.system` = `http://unitsofmeasure.org`
  and `.code` = UCUM code (`[degF]`, `[lb_av]`, `[in_i]`, `mm[Hg]`, `kg`)
- **Impact:** Every vital sign Observation would fail UCUM binding validation.

### Terminology Codes

- **Entity transform:** Local VistA code or pointer value
- **Output examples:** Raw IEN, local lab code, local drug code
- **FHIR R4 requirement:** `coding[].system` must be a full canonical URI
  (`http://loinc.org`, `http://snomed.info/sct`, `http://www.nlm.nih.gov/research/umls/rxnorm`)
  and `coding[].code` must be the standard code from that system
- **Impact:** Every coded element would fail terminology binding validation.

---

## Finding 5 — The Entity File Has No Mechanism for Required-Element Enforcement

FHIR R4 defines required elements (cardinality `1..1` or `1..*`) for every resource type.
For example:

| Resource | Required Elements |
|---|---|
| `Observation` | `status`, `code`, `subject` (for US Core) |
| `Patient` | `identifier` or `name` (for US Core) |
| `MedicationRequest` | `status`, `intent`, `medication[x]`, `subject` |
| `AllergyIntolerance` | `patient`, `code` |
| `Immunization` | `status`, `vaccineCode`, `patient`, `occurrence[x]` |

The Entity file has no concept of required vs. optional items. If a GET ACTION or DATA
TRANSFORM returns empty for a required field — due to missing data, a broken pointer, or
an absent VistA package — the entity simply omits that key. The output is an incomplete
resource with no signal that required elements are absent. There is no pre-emit validation
step in the DDE engine.

---

## Summary

`^DDE` and File #1.5 store everything a FHIR generator needs to *know*: which VistA files
and fields hold clinical data, how to traverse complex multi-file joins, and how to transform
raw VistA values into output-ready strings. The Entity file is a well-structured metadata
registry.

The Entity file and native DDE engine cannot produce valid FHIR R4 JSON for five independent
reasons:

1. **Structural:** The DDE engine's output model (flat key-value) does not match FHIR's
   required deep nesting and array-of-objects structure.
2. **Naming:** VPR Item Names are SDA vocabulary; FHIR clients will not recognize them.
3. **Resource identity:** Several VPR Display Names are not legal FHIR `resourceType` values.
4. **Data types:** Entity transforms produce SDA-format dates, local status codes, raw units,
   and unqualified local codes — none of which satisfy FHIR data type or terminology bindings.
5. **Completeness:** No mechanism exists to enforce FHIR's required-element cardinality
   before emitting an entry.

The correct path forward is an external processor that reads the Entity file metadata and
uses it to drive FHIR-shaped output — applying ISO8601 date conversion, UCUM unit mapping,
standard code system URIs, nested object assembly, and required-element validation.
This is the design the C0FHIR metadata-crawler architecture is attempting to implement.
