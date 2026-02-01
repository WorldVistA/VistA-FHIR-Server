C0FHIRLM ;VAMC/JS-FHIR LAB RESULTS MAPPER ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
GETLAB(BNDL,CNT,LRDFN,VISIT,ENCID) ;Pull Chemistry Labs from VistA File #63
 ; LRDFN: Pointer to File #63; VISIT: Pointer to File #9000010
 Q:'LRDFN!'VISIT
 N LBDT,LRI,LRIDT,TESTIEN,DATA,RESULT,UNIT,TESTNM,LABERR
 ; 1. Get Visit Date (File #9000010: VISIT -> Field .01: VISIT/ADMIT DATE&TIME)
 S LBDT=$$GET1^DIQ(9000010,VISIT_",",.01,"I") Q:'LBDT
 ; 2. Setup Inverse Date Lookup for ^LR(LRDFN,"CH")
 S LRIDT=9999999-LBDT
 S LRI=LRIDT F  S LRI=$O(^LR(LRDFN,"CH",LRI)) Q:'LRI!(LRI>(LRIDT_".9999"))  D
 . S TESTIEN=1 F  S TESTIEN=$O(^LR(LRDFN,"CH",LRI,TESTIEN)) Q:'TESTIEN  D
 .. S DATA=$G(^LR(LRDFN,"CH",LRI,TESTIEN))
 .. S RESULT=$P(DATA,"^",1) ; Field: Result
 .. S UNIT=$P($P(DATA,"^",2),"!",7) ; Field: Units (VA Standard piece)
 .. ; 3. Resolve Test Name (File #60: LABORATORY TEST -> Field .01: NAME)
 .. K TESTNM,LABERR
 .. S TESTNM=$$GET1^DIQ(60,TESTIEN_",",.01,"","","LABERR")
 .. Q:$D(LABERR)!(TESTNM="")
 .. ; 4. Build FHIR Observation Resource
 .. S CNT=CNT+1
 .. S BNDL("entry",CNT,"resource","resourceType")="Observation"
 .. S BNDL("entry",CNT,"resource","category",1,"coding",1,"code")="laboratory"
 .. S BNDL("entry",CNT,"resource","code","text")=TESTNM
 .. S BNDL("entry",CNT,"resource","valueQuantity","value")=RESULT
 .. S BNDL("entry",CNT,"resource","valueQuantity","unit")=UNIT
 .. S BNDL("entry",CNT,"resource","effectiveDateTime")=$$ISO8601^C0FHIRUTL(9999999-LRI)
 .. S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q