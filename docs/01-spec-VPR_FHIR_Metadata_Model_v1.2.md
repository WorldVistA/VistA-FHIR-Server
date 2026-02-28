This consolidated block is designed to be saved directly into **`VPR_FHIR_Metadata_Model_v1.2.md`**. It documents the metadata-driven engine, the core demographic entities, and the mapping logic for your **Build 2** implementation.

---

# ## VPR FHIR Metadata Model Specification (v1.2)

**Project:** VistA VPR FHIR R4 Transition

**Component:** Data Discovery Engine (DDE) Manual Meta-Engine

**Build:** 2 (Metadata-Driven Extraction)

---

## ## 1. Core Architecture: The Manual Meta-Engine

Since the native `DDEOBJ` is unavailable, this build utilizes a recursive Mumps "Crawler" that interprets the `^DDE` (File #1.5) registry.

### ### 1.1 The Extraction Lifecycle

1. **CRAWL**: The engine identifies the `C0FHIR` entity in File #1.5.
2. **GET ACTION (1.1)**: Executes Mumps code to set local context (e.g., `DFN`).
3. **DATA TRANSFORM (1.2)**: Runs raw FileMan values through `C0FHIRUTL` functions.
4. **SETPATH**: Converts dot-notated item names (e.g., `name.0.family`) into nested Mumps arrays for JSON encoding.

---

## ## 2. Entity Registry & Item Mapping

The following entities have been manually copied and refactored into the `C0FHIR` namespace to support FHIR R4 compliance.

### ### 2.1 C0FHIR PATIENT (Top-Level)

| FHIR Path (Item Name) | VistA Field | Mumps Transform |
| --- | --- | --- |
| `identifier.0.system` | N/A | `S VALUE="http://va.gov/viers/icn"` |
| `identifier.0.value` | 991.01 | `S VALUE=$$GET1^DIQ(2,ID,991.01)` |
| `name.0.family` | .01 | `S VALUE=$P(VAL,",",1)` |
| `gender` | .02 | `S VALUE=$S(VAL="M":"male",VAL="F":"female",1:"unknown")` |
| `address` | ENTITY (2) | `Pointer Linkup: S ID=DFN (Target: C0FHIR ADDRESS)` |

### ### 2.2 C0FHIR ADDRESS (Sub-Entity)

| FHIR Path (Item Name) | VistA Field | Mumps Transform |
| --- | --- | --- |
| `address.0.line.0` | .111 | `S VALUE=$$GET1^DIQ(2,ID,.111)` |
| `address.0.city` | .114 | `S VALUE=$$GET1^DIQ(2,ID,.114)` |
| `address.0.state` | .115 | `S VALUE=$$GET1^DIQ(2,ID,.115,"E")` |

---

## ## 3. Transformation Logic (`C0FHIRUTL`)

Standardized functions used across the `^DDE` registry to ensure R4 validity.

* **`$$FHIRDT^C0FHIRUTL`**: Converts FileMan internal dates to ISO-8601.
* **`$$SETPATH^C0FHIRUTL`**: Manages the "Dot-Notation" to M-Array tree conversion.
* **`$$UNIT^C0FHIRUTL`**: Maps VistA Vital types to UCUM unit strings.

---

## ## 4. Verification Checklist

* [ ] Run `D EN^C0FHIRVR` (Verifier) to confirm all `C0FHIR` items use dot-notation.
* [ ] Ensure **File #1.1 (Container)** points to `C0FHIR` Update Entities.
* [ ] Validate exported JSON via `D EXPORT^C0FHIRFX` at `validator.fhir.org`.

---

**Would you like me to now generate the source code block for the `C0FHIR_Implementation_Guide.md` file?**