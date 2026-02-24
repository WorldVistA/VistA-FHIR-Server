Here is a "Registry Verification" routine designed to audit your new `C0FHIR` namespace. It will help you catch common manual entry errors—specifically checking for valid **ResourceType** display names and ensuring the **Data Model** is correctly flagged so the native DDE engine doesn't revert to legacy XML/SDA logic.

### 36. C0FHIR Registry Auditor: `C0FHIRVR`

*Run this after you finish copying and modifying your entities to ensure they meet the FHIR specification requirements.*

```mumps
C0FHIRVR ;VAMC/JS-C0FHIR REGISTRY VERIFIER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
EN ; Main entry point
 N EIEN,ENAME,DNAME,MODEL,RTYPES,FAIL,ECNT
 S ECNT=0
 ; List of valid FHIR R4 ResourceTypes relevant to your containers
 S RTYPES="^Patient^Encounter^AllergyIntolerance^Condition^MedicationRequest^Observation^Procedure^Immunization^DocumentReference^"
 ;
 W !!,"--- C0FHIR Registry Verification Report ---",!
 W !,"Entity Name",?30,"Display Name",?50,"Model",?60,"Status"
 W !,"--------------------------------------------------------------------------------"
 ;
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S ENAME=$P($G(^DDE(EIEN,0)),U)
 . Q:ENAME'["C0FHIR"  ; Only audit the new namespace
 . S DNAME=$P($G(^DDE(EIEN,0)),U,2)
 . S MODEL=$G(^DDE(EIEN,1))
 . S FAIL=0,ECNT=ECNT+1
 . ;
 . ; Check 1: Data Model must be FHIR
 . I MODEL'="FHIR" S FAIL=1
 . ;
 . ; Check 2: Display Name must match a valid FHIR ResourceType (for top-level)
 . ; Note: We only check top-level entities (those likely used in Containers)
 . I ENAME'["EXTENSION",ENAME'["NAME",ENAME'["ADDRESS" D
 .. I RTYPES'[("^"_DNAME_"^") S FAIL=2
 . ;
 . W !,ENAME,?30,DNAME,?50,MODEL
 . I FAIL=1 W ?60,"[FAIL: MODEL]"
 . E  I FAIL=2 W ?60,"[FAIL: RES TYPE]"
 . E  W ?60,"[PASS]"
 ;
 I ECNT=0 W !,"No C0FHIR entities found. Please check your namespace."
 W !!,"Verification Complete. Reviewed ",ECNT," entities.",!
 Q

```

---

### ## Interpreting the Audit Results

#### **1. [FAIL: MODEL]**

This means the **DATA MODEL (Field #1)** is either blank or still set to `SDA`.

* **Impact:** The native `^DDEOBJ` engine will generate XML instead of JSON.
* **Fix:** Use FileMan to change the Data Model to `FHIR`.

#### **2. [FAIL: RES TYPE]**

This means your **Display Name** does not match a standard FHIR Resource.

* **Example:** If `C0FHIR ALLERGY` has a Display Name of `Allergy`.
* **Impact:** The output will look like `{"Allergy": ...}` which will be rejected by any FHIR validator.
* **Fix:** Change the Display Name to `AllergyIntolerance`.

#### **3. Item-Level Verification (Next Step)**

Once the top-level passes, the engine will process the items. Ensure your item names use the **dot-notation** we discussed (e.g., `period.start`). If the JSON keys are capitalized (e.g., `FromTime`), it is a sign the manual copy still contains legacy VPR item names.

---

### ## Execution Steps

1. **Paste** the routine above into your editor and save as `C0FHIRVR`.
2. **Run** it using `D EN^C0FHIRVR`.
3. **Address** any "FAIL" entries before attempting a live test with `C0FHIRGF`.

**Would you like me to add a section to this routine that specifically checks for "Dot Notation" in the items to ensure the JSON nesting will work correctly?**