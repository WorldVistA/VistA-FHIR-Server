C0FHIRAU ;VAMC/JS-FHIR NATIVE DDE AUDITOR ; 21-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 21, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,ENAME,IIEN,INAME,ITYPE,LINK,TRANS,OK
 W !!,"--- C0FHIR Native DDE Compatibility Audit ---",!
 W !,"Entity Name",?35,"Item Name",?60,"Status"
 W !,"--------------------------------------------------------------------------------"
 ;
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S ENAME=$P($G(^DDE(EIEN,0)),U) Q:ENAME'["C0FHIR"
 . ; Check if Entity Model is set to FHIR
 . I $G(^DDE(EIEN,1))'="FHIR" W !,ENAME,?60,"[FAIL: Model not FHIR]"
 . ;
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S NODE=$G(^DDE(EIEN,1,IIEN,0))
 .. S INAME=$P(NODE,U),ITYPE=$P(NODE,U,4),LINK=$P(NODE,U,11)
 .. S TRANS=$G(^DDE(EIEN,1,IIEN,1.2)) ; The M code transform
 .. ;
 .. ; Rule: If Item is an ENTITY, it MUST have a Pointer Linkup or a GET Action
 .. I ITYPE=2 D
 ... S OK=0 I LINK'=""!(TRANS'="") S OK=1
 ... W !,ENAME,?35,$E(INAME,1,23)
 ... I OK W ?60,"[OK]"
 ... E  W ?60,"[FAIL: No Linkage]"
 ;
 W !!,"Audit Complete.",!
 Q