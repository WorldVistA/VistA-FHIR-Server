C0FHIRVR ;VAMC/JS-FHIR ENTITY AUDIT REPORT ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,ENAME,DFILE,DMODEL,DNAME,CNT,FCNT,SCNT
 S (CNT,FCNT,SCNT)=0
 W !!,"--- C0FHIR Entity Registry Audit Report ---",!
 W !,"ID",?6,"Entity Name",?35,"File",?45,"Model",?55,"Display Name"
 W !,"--------------------------------------------------------------------------------",!
 ;
 S ENAME="VPR" ; Start with VPR namespace established in Build 2
 F  S ENAME=$O(^DDE("B",ENAME)) Q:ENAME=""!(ENAME'["VPR")  D
 . S EIEN=0 F  S EIEN=$O(^DDE("B",ENAME,EIEN)) Q:'EIEN  D
 .. S CNT=CNT+1
 .. S DFILE=$$GET1^DIQ(1.1,EIEN_",",.02)
 .. S DMODEL=$$GET1^DIQ(1.1,EIEN_",",1)
 .. S DNAME=$$GET1^DIQ(1.1,EIEN_",",.04)
 .. ;
 .. I DMODEL="FHIR" S FCNT=FCNT+1
 .. E  S SCNT=SCNT+1
 .. ;
 .. W !,EIEN,?6,$E(ENAME,1,28),?35,DFILE,?45,DMODEL,?55,$E(DNAME,1,24)
 ;
 W !!,"--- Audit Summary ---"
 W !,"Total VPR Entities:    "_CNT
 W !,"FHIR Model Updated:    "_FCNT
 W !,"Legacy/SDA Model:      "_SCNT
 W !,"Registry Integrity:    "_$S(SCNT=0:"100% (READY)",1:"INCOMPLETE")
 W !!,"End of Report.",!
 Q