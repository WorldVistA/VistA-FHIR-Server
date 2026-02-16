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