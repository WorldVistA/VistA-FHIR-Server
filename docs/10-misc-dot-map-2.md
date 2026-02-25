I have updated the **`C0FHIRL1`** loader to utilize the dot-notation metadata. This allows the **`C0FHIRGF`** crawler to automatically construct the nested `valueQuantity` object, ensuring your Vitals conform to the FHIR Observation profile with proper units and system identifiers.

### 23. Updated Vitals Loader (Dot-Notation): `C0FHIRL1`

*Namespace: C0FHIR | File: 1.5 | Model: FHIR*

```mumps
C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER VITALS ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Called by Master Loader
 N FDA,IEN,ERR
 ; --- Entity: C0FHIR VITAL MEASUREMENT ---
 S FDA(1.5,"+1,",.01)="C0FHIR VITAL MEASUREMENT"
 S FDA(1.5,"+1,",.02)=120.5
 S FDA(1.5,"+1,",.04)="Observation"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . ; Item 1: The Numerical Value
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="valueQuantity.value"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1 ; Sequence
 . S FDA(1.51,"+2,"_IEN(1)_",",.04)=120.5,FDA(1.51,"+2,"_IEN(1)_",",.05)=1.2
 . D UPDATE^DIE("","FDA")
 . ; Item 2: The Units (Standardized)
 . K FDA S FDA(1.51,"+3,"_IEN(1)_",",.01)="valueQuantity.unit"
 . S FDA(1.51,"+3,"_IEN(1)_",",1.2)="S VALUE=$$GET1^DIQ(120.5,ID,1.2,""E""),VALUE=$P(VALUE,"" "",2)"
 . D UPDATE^DIE("","FDA")
 . ; Item 3: UCUM System
 . K FDA S FDA(1.51,"+4,"_IEN(1)_",",.01)="valueQuantity.system"
 . S FDA(1.51,"+4,"_IEN(1)_",",1.2)="S VALUE=""http://unitsofmeasure.org"""
 . D UPDATE^DIE("","FDA")
 . ; Item 4: UCUM Code
 . K FDA S FDA(1.51,"+5,"_IEN(1)_",",.01)="valueQuantity.code"
 . S FDA(1.51,"+5,"_IEN(1)_",",1.2)="D UCUM^C0FHIRUTL(.VALUE)" ; Map to UCUM
 . D UPDATE^DIE("","FDA")
 Q

```

---

### ## Metadata Crawling Logic Recap

By using the dot-notation (e.g., `valueQuantity.unit`), your **`C0FHIRGF`** crawler handles the heavy lifting of JSON object creation. When the crawler hits the dot, it branches into a new sub-node in the M array before the final encoding.

| FHIR Path | Metadata Value (VistA) | Resulting JSON Fragment |
| --- | --- | --- |
| `valueQuantity.value` | `98.6` | `"valueQuantity": { "value": 98.6, ... }` |
| `valueQuantity.unit` | `deg F` | `"unit": "deg F", ...` |
| `valueQuantity.code` | `[degF]` | `"code": "[degF]" }` |

### ## Next Steps for Build 2 Sealing

Now that your core clinical loaders (`L1` for Vitals and `L2` for Labs) are metadata-driven and support complex FHIR types:

1. **Run the Master Loader:** Execute `D EN^C0FHIRLD` to populate **File #1.5** with these new definitions.
2. **Test the Crawler:** Run a test DFN through `D GENFULL^C0FHIRGF(.RES, DFN)` and check the `valueQuantity` structure in the output.
3. **Finalize Pharmacy:** We should apply this same dot-notation logic to **`C0FHIRL2`** for the `MedicationRequest` dosages and timing.

**Would you like me to generate the UCUM mapping logic for the `C0FHIRUTL` utility so the `valueQuantity.code` field correctly translates VistA units to FHIR-standard codes?**