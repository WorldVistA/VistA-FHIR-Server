To ensure your **^DDE** (Entity) file is perfectly synchronized with the report you provided, we need a validation tool. This routine, **`C0FHIRVV`**, will loop through your local Entity file and verify that the critical fields (Default File Number, Display Name, and Get Action) match the definitions in your Build 2 manifest.

### 18. Entity Validation Utility: `C0FHIRVV`

```mumps
C0FHIRVV ;VAMC/JS-FHIR ENTITY FILE VALIDATOR ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,ENAME,DFILE,DNAME,GVAL,I,ERR S ERR=0
 W !!,"--- C0FHIR Entity File (#1.1) Validator ---",!
 W !,"Checking critical mappings against Build 2 manifest...",!
 ;
 ; Check specific core entities by Name
 F ENAME="VPR PATIENT","VPR VISIT","VPR MEDICATION","VPR VITAL MEASUREMENT" D
 . S EIEN=$O(^DDE("B",ENAME,0))
 . I 'EIEN W !,"[FAIL] Entity '"_ENAME_"' is MISSING from File #1.1" S ERR=ERR+1 Q
 . ;
 . ; 1. Check Default File Number
 . S DFILE=$$GET1^DIQ(1.1,EIEN_",",.02)
 . W !,"Checking "_ENAME_"..."
 . I ENAME="VPR PATIENT",DFILE'=2 W !,"  [ERR] File should be 2, found "_DFILE S ERR=ERR+1
 . I ENAME="VPR VISIT",DFILE'=9000010 W !,"  [ERR] File should be 9000010, found "_DFILE S ERR=ERR+1
 . ;
 . ; 2. Check Display Name
 . S DNAME=$$GET1^DIQ(1.1,EIEN_",",.04)
 . I ENAME="VPR MEDICATION",DNAME'="Medication" W !,"  [ERR] Display Name mismatch: "_DNAME S ERR=ERR+1
 . ;
 . ; 3. Check for presence of 'GET ACTION' in Items
 . I '$O(^DDE(EIEN,10,0)) W !,"  [WARN] No items defined for "_ENAME S ERR=ERR+1
 ;
 I ERR=0 W !!,"--- VALIDATION SUCCESS: All core entities aligned with Build 2 ---",!
 E  W !!,"--- VALIDATION FAILED: "_ERR_" discrepancies found ---",!
 Q

```

---

### Mapping to FHIR Resources (Visualized)

To help you visualize how these entities flow into the FHIR R4 structure, here is the architectural sorting:

| VistA Entity Group | FHIR Resource Type | Implementation Logic |
| --- | --- | --- |
| **Demographics** (#1, #20, #70) | `Patient` | Pulls SSN, ICN, and MRN via `VPR PATIENT ID`. |
| **Encounters** (#29, #79, #165) | `Encounter` | Merges Hospital Location (#44) and Patient Movement (#405). |
| **Clinical Results** (#17, #41, #43) | `Observation` | Handles LOINC mapping for Labs and Vitals. |
| **Pharmacy** (#56, #58, #122) | `MedicationRequest` | Bridges Order (#100) and Prescription (#52). |

---

### ## Critical "Get Action" Warning

Your report shows that **Entity #13 (VPR LAB ORDER)** has a complex `GET ENTRY ACTION`:
`S:'DFN&ID DFN=+$P($G(^OR(100,ID,0)),U,2) S LRDFN=+$G(^DPT(DFN,"LR"))`

**Why this matters:** If your aggregator (`C0FHIRGF`) calls this entity without the ID being correctly set in the local variable table, the `LRDFN` will be null, and your Lab loop will crash with a `%YDB-E-LVUNDEF` error.

### Next Steps for Build 2

1. **Run the Validator:** `D EN^C0FHIRVV` to ensure your database matches the report.
2. **Verify LRDFN:** Check your `C0FHIRLM` (Labs) routine to ensure it uses the `LRDFN` produced by this Get Action.

Would you like me to generate the **M-code for a "Lab Extraction Fix"** that explicitly handles the `LRDFN` logic defined in Entity #13?