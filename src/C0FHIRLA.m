C0FHIRLA ;VAMC/JS-LAB TEST LOINC AUDITOR ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Main entry point
 N TST,TNAME,LOINC,Wptr,SPEC,TOTAL,MISS,CNT S (TOTAL,MISS,CNT)=0
 W !!,"--- C0FHIR Lab-to-LOINC (via WKLD) Audit ---",!
 ;
 S TST=0 F  S TST=$O(^LAB(60,TST)) Q:'TST  D
 . S TNAME=$$GET1^DIQ(60,TST_",",.01)
 . ; Check Site/Specimen multiple for WKLD Code
 . S SPEC=$O(^LAB(60,TST,1,0)) Q:'SPEC
 . S Wptr=$$GET1^DIQ(60.01,SPEC_","_TST_",",2,"I") ; Pointer to File #64
 . I 'Wptr S LOINC="MISSING WKLD" G DISP
 . ; Get LOINC from WKLD CODE file (#64), Field #25
 . S LOINC=$$GET1^DIQ(64,Wptr_",",25)
 . S:LOINC="" LOINC="MISSING LOINC"
 . ;
DISP . S TOTAL=TOTAL+1
 . I LOINC["MISSING" S MISS=MISS+1
 . I CNT<20!(LOINC["MISSING") D
 .. S CNT=CNT+1
 .. W !,TNAME,?35,$S(LOINC["MISSING":"[!!]",1:"[OK]"),?50,LOINC
 ;
 W !!,"--- Audit Summary ---"
 W !,"Total Tests Evaluated: "_TOTAL
 W !,"Mapping Coverage:      "_$J((TOTAL-MISS)/TOTAL*100,0,1)_"%",!
 Q