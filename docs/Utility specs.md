Here is the full code for the **C0FHIRUTL** utility routine. This routine serves as the "Swiss Army Knife" for your metadata-driven engine, handling path normalization for `XLFJSON`, date conversions, and standardized clinical terminology lookups.

### ## C0FHIRUTL: FHIR Metadata & Terminology Utilities

```mumps
C0FHIRUTL ;VAMC/JS-FHIR UTILITY TRANSFORMS ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
SETPATH(TARGET,PATH,VAL) ; Build nested M-array from dot-notated path
 ; Input: TARGET - Array passed by reference (e.g., .MAP)
 ;        PATH   - The FHIR path string (e.g., "name.0.family")
 ;        VAL    - The value to set at that leaf
 ;
 N I,NODE,STR
 S STR="TARGET"
 ; Iterate through each segment of the path delimited by "."
 F I=1:1:$L(PATH,".") D
 . S NODE=$P(PATH,".",I)
 . ; If the node is numeric, it represents a JSON array index
 . I NODE=+NODE S STR=STR_"("_NODE_")"
 . ; Otherwise, it is a standard JSON object key
 . E  S STR=STR_"("""_NODE_""")"
 ;
 ; Execute the dynamic set command
 S @STR=VAL
 Q
 ;
FHIRDT(VADATE) ; Standardized Date Transformer
 ; Input: VADATE - FileMan internal date format
 ; Output: ISO-8601 formatted date/time
 Q:VADATE="" ""
 Q $$DATE^VPRSDA(VADATE)
 ;
LOINC(VITAL) ; Map Vital Type to LOINC
 ; Input: VITAL - IEN from File #120.51
 ; Output: LOINC Code
 N RES S RES=$$GET1^DIQ(120.51,VITAL,99.99) ; Assumes custom LOINC field mapping
 I RES="" S RES=$S(VITAL=1:"8480-6",VITAL=2:"8462-4",VITAL=3:"8867-4",1:"")
 Q RES
 ;
CVX(IMM) ; Map Immunization to CVX
 ; Input: IMM - IEN from File #9999999.14
 ; Output: CVX Code
 Q $$GET1^DIQ(9999999.14,IMM,.03)
 ;
RXNORM(DRUG) ; Map Drug to RxNorm
 ; Input: DRUG - IEN from File #50
 ; Output: RxNorm CUI
 N NDF,VAP S NDF=$$GET1^DIQ(50,DRUG,22,"I") ; Pointer to NDF
 S VAP=$$GET1^DIQ(50.68,NDF,19) ; RxNorm field in PSNDF
 Q VAP
 ;
UNIT(TYPE) ; Map VistA Vital units to UCUM
 ; Input: TYPE - Vital Type (e.g., "T", "P", "BP")
 Q:TYPE="T" "[degF]"
 Q:TYPE="W" "[lb_av]"
 Q:TYPE="H" "[in_us]"
 Q ""
 ;
REF(TYPE,IEN) ; Generate a FHIR Resource Reference string
 ; Input: TYPE - Resource Type (e.g., "Patient")
 ;        IEN  - VistA internal entry number
 Q:IEN="" ""
 Q TYPE_"/"_IEN

```

---

### ## Key Subroutine Breakdown

#### ### 1. `SETPATH` (The JSON Constructor)

This is the core of your new metadata engine. It interprets the `ITEM NAME` in File #1.5 as a tree structure.

* **Input:** `name.0.given.0`
* **Execution:** Dynamically creates `TARGET("name",0,"given",0) = VALUE`.
* **Output:** When passed to `ENCODE^XLFJSON`, it produces standard nested FHIR arrays.

#### ### 2. `FHIRDT` (Temporal Normalization)

VistA stores dates as `3260224.1655`. FHIR requires ISO-8601 (`2026-02-24T16:55:00Z`). This routine wraps the standard VPR date logic to ensure consistency across all resources.

#### ### 3. Terminology Wrappers (`LOINC`, `CVX`, `RXNORM`)

These handle the "Terminology Hop."

* **VistA:** Uses internal pointers (e.g., File #50 for Drugs).
* **FHIR:** Requires standardized codes (e.g., RxNorm).
* **Integration:** These functions allow you to keep your `GET ACTION` logic in File #1.5 very clean: `S VALUE=$$RXNORM^C0FHIRUTL(VAL)`.

---

### ## Implementation Note

When you are manually copying and modifying your entities, you should predominantly use these utility calls in the **DATA TRANSFORM (Field #1.2)**.

**Example for `C0FHIR OBSERVATION`:**

* **Item Name:** `valueQuantity.unit`
* **Transform:** `S VALUE=$$UNIT^C0FHIRUTL("T")`

**Now that the Utility routine is ready, would you like me to generate the spec for the final `C0FHIR PATIENT` items to ensure the ICN and SSN follow the proper `identifier` array structure?**