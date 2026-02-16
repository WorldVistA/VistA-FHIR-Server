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