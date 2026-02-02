C0FHIRLM ;VAMC/JS-FHIR LAB RESULTS MAPPER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETLAB(BNDL,CNT,LRDFN,VISIT,ENCID) ;VistA File #63 (LAB DATA)
 Q:'LRDFN!'VISIT
 N LBDT,LRI,LRIDT,TESTIEN,DATA,RESULT,UNIT,TESTNM,LABERR
 S LBDT=$$GET1^DIQ(9000010,VISIT_",",.01,"I") Q:'LBDT
 S LRIDT=9999999-LBDT,LRI=LRIDT
 F  S LRI=$O(^LR(LRDFN,"CH",LRI)) Q:'LRI!(LRI>(LRIDT_".9999"))  D
 . S TESTIEN=1 F  S TESTIEN=$O(^LR(LRDFN,"CH",LRI,TESTIEN)) Q:'TESTIEN  D
 .. S DATA=$G(^LR(LRDFN,"CH",LRI,TESTIEN))
 .. S RESULT=$P(DATA,"^",1),UNIT=$P($P(DATA,"^",2),"!",7)
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