Here is the complete source code block for the `C0FHIR_Implementation_Guide.md` file. You can copy this entire section directly into your documentation file to maintain the "source of truth" for the `C0FHIR` toolkit.

---

# C0FHIR_Implementation_Guide.md

This guide details the deployment and architecture of the `C0FHIR` toolkit. This toolkit replaces the native `DDEOBJ` by implementing a metadata-driven extraction engine that parses the `^DDE` registry to generate FHIR R4 JSON.

## 1. Core Extraction Driver: `C0FHIRGF`

The primary entry point. It crawls the `^DDE` registry, executes transforms, and bundles the result into a FHIR `collection` bundle.

```mumps
C0FHIRGF ;VAMC/JS-FHIR NATIVE DDE WRAPPER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
GENFULL(RESULT,DFN) ; Generate full FHIR Patient Bundle
 N BNDL,CNT,GLB
 S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 D CRAWL("C0FHIR PATIENT ID",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR VITAL MEASUREMENT",DFN,.BNDL,.CNT)
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
CRAWL(ENAME,ID,BNDL,CNT) ; Interpret ^DDE registry
 N EIEN,IIEN,TAG,FILE,FLD,X11,X12,VAL,VALUE,RES,MAP,ITEM
 S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 S RES=$P($G(^DDE(EIEN,0)),U,5)
 S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 . S ITEM=$G(^DDE(EIEN,1,IIEN,0)),TAG=$P(ITEM,U)
 . S FILE=+$P(ITEM,U,4),FLD=$P(ITEM,U,5)
 . S X11=$G(^DDE(EIEN,1,IIEN,1)) I X11'="" X X11
 . S VAL="" I FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . S X12=$G(^DDE(EIEN,1,IIEN,1.2))
 . I X12'="" S VALUE=VAL X X12 S VAL=VALUE
 . I $G(VAL)'="" D SETPATH^C0FHIRUTL(.MAP,TAG,VAL)
 I $D(MAP) S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")=RES M BNDL("entry",CNT,"resource")=MAP
 Q

```

---

## 2. FHIR Utility Library: `C0FHIRUTL`

Handles path parsing for nested JSON objects and standardizes clinical data (Dates, Units, Codes).

```mumps
C0FHIRUTL ;VAMC/JS-FHIR UTILITY TRANSFORMS ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
SETPATH(TARGET,PATH,VAL) ; Build nested M-array from dot-notated path
 N I,NODE,STR
 S STR="TARGET"
 F I=1:1:$L(PATH,".") D
 . S NODE=$P(PATH,".",I)
 . I NODE=+NODE S STR=STR_"("_NODE_")"
 . E  S STR=STR_"("""_NODE_""")"
 S @STR=VAL
 Q
 ;
FHIRDT(VADATE) ; Date to ISO-8601
 Q:VADATE="" "" Q $$DATE^VPRSDA(VADATE)
 ;
LOINC(VITAL) ; Simple LOINC lookup
 N RES S RES=$$GET1^DIQ(120.51,VITAL,99.99)
 Q $S(RES'="":RES,VITAL=1:"8480-6",VITAL=2:"8462-4",1:"")

```

---

## 3. Registry Auditor: `C0FHIRVR`

Ensures all manual entries in the `^DDE` registry meet FHIR structural requirements (Dot-Notation, Correct Model flags).

```mumps
C0FHIRVR ;VAMC/JS-FHIR REGISTRY VERIFIER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
EN ; Audit registry
 N EIEN,ENAME,DNAME,MODEL,IIEN,INAME
 W !,"--- C0FHIR Registry Audit ---"
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S ENAME=$P($G(^DDE(EIEN,0)),U) Q:ENAME'["C0FHIR"
 . S MODEL=$G(^DDE(EIEN,1))
 . I MODEL'="FHIR" W !,ENAME," [FAIL: Model]" Q
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S INAME=$P($G(^DDE(EIEN,1,IIEN,0)),U)
 .. I INAME'["." W !,ENAME," [WARN: No Dot Notation in ",INAME,"]"
 W !,"Audit Complete."
 Q

```

---

**Would you like me to generate the source for the final `C0FHIRFX` exporter, or are you ready to compile the full documentation into your repository?**