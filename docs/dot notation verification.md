C0FHIRVR ;VAMC/JS-C0FHIR REGISTRY VERIFIER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
EN ; Main entry point
 N EIEN,ENAME,DNAME,MODEL,RTYPES,FAIL,ECNT,IIEN,INAME,DOTS
 S ECNT=0
 ; Valid FHIR R4 ResourceTypes
 S RTYPES="^Patient^Encounter^AllergyIntolerance^Condition^MedicationRequest^Observation^Procedure^Immunization^DocumentReference^"
 ;
 W !!,"--- C0FHIR Registry & Dot-Notation Audit ---",!
 W !,"Entity Name",?30,"Display Name",?50,"Status/Warning"
 W !,"--------------------------------------------------------------------------------"
 ;
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S ENAME=$P($G(^DDE(EIEN,0)),U)
 . Q:ENAME'["C0FHIR"
 . S DNAME=$P($G(^DDE(EIEN,0)),U,2)
 . S MODEL=$G(^DDE(EIEN,1))
 . S ECNT=ECNT+1
 . ;
 . ; Initial Check: Data Model and Resource Name
 . I MODEL'="FHIR" W !,ENAME,?30,DNAME,?50,"[FAIL: Model not FHIR]" Q
 . I ENAME'["EXTENSION",RTYPES'[("^"_DNAME_"^") W !,ENAME,?30,DNAME,?50,"[FAIL: Invalid ResType]" Q
 . ;
 . ; Item-Level Audit for Dot Notation
 . S (FAIL,DOTS)=0
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S INAME=$P($G(^DDE(EIEN,1,IIEN,0)),U)
 .. ; If the name starts with a Capital letter and has no dots, it's likely a legacy SDA name
 .. I $E(INAME)?1U,INAME'["." S FAIL=1
 .. I INAME["." S DOTS=1
 . ;
 . W !,ENAME,?30,DNAME
 . I FAIL,ENAME'["EXTENSION" W ?50,"[WARN: Legacy SDA Names?]"
 . E  I DOTS W ?50,"[PASS: FHIR Structured]"
 . E  W ?50,"[PASS]"
 ;
 W !!,"Audit Complete. Reviewed ",ECNT," entities.",!
 Q