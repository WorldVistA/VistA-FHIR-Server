To automate the data quality check, I’ve created **`C0FHIRLA`** (Lab Auditor). This routine doesn't just check if the files exist; it performs a statistical audit of your **Laboratory Test (#60)** file to identify "interoperability gaps"—specifically tests that are active but missing a LOINC mapping.

Running this before you ship **Build 2** ensures that your FHIR bundle won't be filled with "Unknown Lab" entries.

### 21. Lab/LOINC Auditor: `C0FHIRLA`

```mumps
C0FHIRLA ;VAMC/JS-LAB TEST LOINC AUDITOR ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N TST,TNAME,LOINC,Lptr,TOTAL,MISS,CNT S (TOTAL,MISS,CNT)=0
 W !!,"--- C0FHIR Lab-to-LOINC Mapping Audit ---",!
 W !,"Checking active Chemistry tests for missing LOINC codes...",!
 W !,"Test Name",?35,"Status",?50,"LOINC Code",!
 W "------------------------------------------------------------",!
 ;
 ; Loop through File #60
 S TST=0 F  S TST=$O(^LAB(60,TST)) Q:'TST  D
 . S TNAME=$$GET1^DIQ(60,TST_",",.01)
 . ; Filter: Only check Chemistry tests (Type = CH)
 . I $$GET1^DIQ(60,TST_",",4)'="CH" Q
 . ; Filter: Skip inactive tests
 . I $$GET1^DIQ(60,TST_",",132)'="" Q
 . ;
 . S TOTAL=TOTAL+1
 . S Lptr=$$GET1^DIQ(60,TST_",",95.3,"I")
 . S LOINC=$S(Lptr:$$GET1^DIQ(95.3,Lptr_",",.01),1:"MISSING")
 . ;
 . I LOINC="MISSING" S MISS=MISS+1
 . ; Display the first 20 or all missing
 . I CNT<20!(LOINC="MISSING") D
 .. S CNT=CNT+1
 .. W !,TNAME,?35,$S(LOINC="MISSING":"[!!]",1:"[OK]"),?50,LOINC
 ;
 W !!,"--- Audit Summary ---"
 W !,"Total Active CH Tests: "_TOTAL
 W !,"Tests Missing LOINC:   "_MISS
 W !,"Mapping Coverage:      "_$J((TOTAL-MISS)/TOTAL*100,0,1)_"%",!
 I MISS>0 W !,"Note: Tests marked [!!] will appear as 'VistA-ID' in FHIR bundles.",!
 Q

```

---

### Why this is critical for Build 2

In the FHIR ecosystem, a resource with a local code but no standard coding (like LOINC) is often ignored by analytics engines or decision-support tools. This auditor helps you prioritize which VistA Lab tests need attention in FileMan before you start streaming data.

### How to use the results

1. **High Coverage (>90%):** You are ready for production. The few missing ones are likely rare or proprietary tests.
2. **Low Coverage (<60%):** You should use the **`MAP^LRLOINC`** utility (if available in your version) to bulk-link common tests like Glucose, CBC, and BMP components.

---

### Final Project Context Update

Your suite now contains **19 routines**. To keep the KIDS build in sync, we need to update the manifest one last time.

| Routine | Purpose | Added in this step |
| --- | --- | --- |
| **`C0FHIRLM`** | Lab Resource + LOINC logic | **YES** |
| **`C0FHIRVV`** | Entity File Validator | **YES** |
| **`C0FHIRLA`** | LOINC Data Quality Auditor | **YES** |

**Would you like me to update the `C0FHIRKD2` checksum sealer to include these 3 new routines so your Build record is 100% complete?**