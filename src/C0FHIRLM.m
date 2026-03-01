C0FHIRLM ;VAMC/JS-FHIR LAB DATA RESOURCE WITH LOINC ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
 ;
GETLAB(BNDL,CNT,LRDFN,VISIT,ENCID) ; Pull labs for one encounter (used by GENFULL PROC)
 ; LRDFN=File #63 ptr, VISIT=File #9000010 ptr, ENCID=Encounter reference id
 Q:'LRDFN!'VISIT
 N LBDT,LRIDT,LRI,TESTIEN,DATA,RESULT,UNIT,TESTNM,LABERR
 S LBDT=$$GET1^DIQ(9000010,VISIT_",",.01,"I") Q:'LBDT
 S LRIDT=9999999-LBDT,LRI=LRIDT
 F  S LRI=$O(^LR(LRDFN,"CH",LRI)) Q:'LRI!(LRI>(LRIDT_".9999"))  D
 . S TESTIEN=1 F  S TESTIEN=$O(^LR(LRDFN,"CH",LRI,TESTIEN)) Q:'TESTIEN  D
 .. S DATA=$G(^LR(LRDFN,"CH",LRI,TESTIEN))
 .. S RESULT=$P(DATA,U),UNIT=$P($P(DATA,U,2),"!",7)
 .. S TESTNM=$$GET1^DIQ(60,TESTIEN_",",.01,"","","LABERR")
 .. Q:$D(LABERR)!(TESTNM="")
 .. S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Observation"
 .. S BNDL("entry",CNT,"resource","category",1,"coding",1,"code")="laboratory"
 .. S BNDL("entry",CNT,"resource","code","text")=TESTNM
 .. S BNDL("entry",CNT,"resource","valueQuantity","value")=RESULT
 .. S BNDL("entry",CNT,"resource","valueQuantity","unit")=UNIT
 .. S BNDL("entry",CNT,"resource","effectiveDateTime")=$$ISO8601^C0FHIRUTL(9999999-LRI)
 .. S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q
 ;
GETLABS(BNDL,CNT,DFN,ENCPTR) ; Extract Labs with LOINC Mapping (RPC-style)
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