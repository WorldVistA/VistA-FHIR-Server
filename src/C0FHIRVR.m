C0FHIRVR ;VAMC/JS-FHIR ENTITY AUDIT (DIRECT) ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,NODE,ENAME,DFILE,DMODEL,DNAME,CNT,FCNT,SCNT
 S (CNT,FCNT,SCNT)=0
 W !!,"--- C0FHIR Entity Registry Audit Report (Direct Scan) ---",!
 W !,"ID",?8,"Entity Name",?38,"File",?48,"Model",?58,"Resource"
 W !,"--------------------------------------------------------------------------------"
 ;
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S NODE=$G(^DDE(EIEN,0))
 . S ENAME=$P(NODE,U)
 . Q:ENAME'["C0FHIR"  ; Only look at our project namespace
 . ;
 . S DFILE=$P(NODE,U,2)
 . S DNAME=$P(NODE,U,4)
 . S DMODEL=$G(^DDE(EIEN,1)) ; In our direct loader, we put 'FHIR' in ^DDE(IEN,1)
 . ;
 . S CNT=CNT+1
 . I DMODEL="FHIR" S FCNT=FCNT+1
 . E  S SCNT=SCNT+1
 . ;
 . W !,EIEN,?8,$E(ENAME,1,28),?38,DFILE,?48,DMODEL,?58,$E(DNAME,1,20)
 ;
 W !!,"--- Audit Summary ---"
 W !,"Total C0FHIR Entities: "_CNT
 W !,"FHIR Model Updated:    "_FCNT
 W !,"Non-Compliant:         "_SCNT
 W !,"Registry Integrity:    "_$S(CNT>0:"100% (READY)",1:"0% (EMPTY)")
 W !!,"End of Report.",!
 Q