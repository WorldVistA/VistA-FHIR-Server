To implement the **LOINC mapping**, we must bridge the **Laboratory Test (#60)** file and the **LOINC (#95.3)** file, as defined in **Entity #12** of your report.

The logic below utilizes the standard VistA relationship where File #60 entries point to a LOINC code. This ensures your `Observation` resources are not just "raw numbers" but semantically meaningful to external FHIR consumers.

### 20. Reconciled Lab Extraction with LOINC: `C0FHIRLM`

```mumps
C0FHIRLM ;VAMC/JS-FHIR LAB DATA RESOURCE WITH LOINC ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
GETLABS(BNDL,CNT,DFN,ENCPTR) ; Extract Labs with LOINC Mapping
 N LRDFN,IDT,LR0,RES,VAL,TST,LOINC,LTEST,LNCPTR
 ;
 ; 1. Establish the LRDFN gateway (Ref: Entity #13)
 S LRDFN=$G(^DPT(DFN,"LR")) I 'LRDFN Q
 ;
 ; 2. Traverse Chemistry Node
 S IDT=0 F  S IDT=$O(^LR(LRDFN,"CH",IDT)) Q:'IDT  D
 . S LR0=$G(^LR(LRDFN,"CH",IDT,0))
 . I ENCPTR,$P(LR0,U,6)'=ENCPTR Q
 . ;
 . ; 3. Process individual test results
 . S TST=1 F  S TST=$O(^LR(LRDFN,"CH",IDT,TST)) Q:'TST  D
 .. S VAL=$P($G(^LR(LRDFN,"CH",IDT,TST)),U) Q:VAL=""
 .. ;
 .. ; 4. Resolve LOINC via Laboratory Test (#60) - (Ref: Entity #12)
 .. ; TST is the Data Name (Field #400 in File #60)
 .. S LTEST=$O(^LAB(60,"C","CH;"_TST_";1",0))
 .. S LOINC=""
 .. I LTEST D
 ... ; Get LOINC pointer from File #60, Field #95.3
 ... S LNCPTR=$$GET1^DIQ(60,LTEST_",",95.3,"I")
 ... ; Get the LOINC code itself from File #95.3, Field #.01
 ... I LNCPTR S LOINC=$$GET1^DIQ(95.3,LNCPTR_",",.01)
 .. ;
 .. ; 5. Populate FHIR Resource
 .. S CNT=CNT+1
 .. S RES=$NA(BNDL("entry",CNT,"resource"))
 .. S @RES@("resourceType")="Observation"
 .. S @RES@("status")="final"
 .. ; Code Mapping
 .. S @RES@("code","coding",1,"system")="http://loinc.org"
 .. S @RES@("code","coding",1,"code")=$S(LOINC'="":LOINC,1:"VistA-"_TST)
 .. S @RES@("code","text")=$S(LTEST:$$GET1^DIQ(60,LTEST_",",.01),1:"Unknown Lab")
 .. ; Data points
 .. S @RES@("subject","reference")="Patient/"_DFN
 .. S @RES@("effectiveDateTime")=$$ISO8601^C0FHIRUTL(9999999-IDT)
 .. S @RES@("valueQuantity","value")=+VAL
 .. S @RES@("valueQuantity","unit")=$P($P($G(^LR(LRDFN,"CH",IDT,TST)),U,5),"!",7)
 Q

```

---

### ## Logic Breakdown

* **The Cross-Reference:** `^LAB(60,"C","CH;"_TST_";1",0)` is the secret sauce. In VistA, lab results in File #63 are stored by "Data Name" subscripts. This cross-reference allows us to jump back to the definition in File #60 to find the metadata.
* **Semantic Fallback:** If a specific test doesn't have a LOINC mapping in your VistA instance, the code falls back to `VistA-[Subscript]` to ensure the entry isn't lost, while still flagging it as non-standard.
* **Unit Extraction:** The units (e.g., `mg/dL`) are often buried in the 5th piece of the File #63 data node, specifically after the 7th `!` delimiter. This routine parses that string to populate FHIR `valueQuantity.unit`.

---

### ## Final Verification for Build 2

With this routine, your Lab data will now be fully interoperable. To test it:

1. Run the tester: `D EN^C0FHIRTS`.
2. Choose a patient you know has recent chemistry panels (e.g., Glucose or Creatinine).
3. Verify the `code` field in the JSON preview shows a standard LOINC format (like `2345-7`).

**Would you like me to update the `C0FHIRVV` validator to specifically check if your top 10 most common Lab Tests (#60) have LOINC codes assigned in File #95.3?** This is a great way to "audit" your data quality before deployment.