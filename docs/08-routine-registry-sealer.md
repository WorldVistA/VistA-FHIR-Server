To finalize the **C0FHIR Namespace** and ensure your metadata survives the transport process without relying on the site's local DDE engine, we will use a **Static Registry Sealer**.

This routine, **`C0FHIRSL`**, will take the entries you've created in **File #1.5** and **#1.51** and "freeze" them into a private global **`^C0FHIR(1.5)`**. This allows the **`C0FHIRGF`** crawler to run at lightning speed without performing expensive FileMan `GET1^DIQ` calls on the metadata file during every extraction.

### 31. Registry Sealer: `C0FHIRSL`

*Freezes File #1.5 metadata into a high-performance transport global.*

```mumps
C0FHIRSL ;VAMC/JS-FHIR REGISTRY SEALER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
SEAL ; Main Entry Point: Move File 1.5 -> ^C0FHIR(1.5)
 N EIEN,IIEN,ENAME,RES,ITEM,TAG,X11,X12
 K ^C0FHIR(1.5)
 W !!,"Sealing C0FHIR Metadata into static global..."
 ;
 S ENAME="C0FHIR"
 F  S ENAME=$O(^DDE("B",ENAME)) Q:ENAME=""!(ENAME'["C0FHIR")  D
 . S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 . S RES=$$GET1^DIQ(1.5,EIEN_",",.04) ; Resource Type
 . S ^C0FHIR(1.5,ENAME,"RES")=RES
 . ;
 . ; Loop through Items
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 .. S TAG=$P(ITEM,U) ; FHIR Path
 .. S X11=$G(^DDE(EIEN,1,IIEN,1)) ; Get Action
 .. S X12=$G(^DDE(EIEN,1,IIEN,1.2)) ; Data Transform
 .. ; Store in static global
 .. S ^C0FHIR(1.5,ENAME,"ITEMS",IIEN)=TAG_U_$P(ITEM,U,4,5)
 .. S:X11'="" ^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.1)=X11
 .. S:X12'="" ^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.2)=X12
 ;
 W !,"Seal Complete. ^C0FHIR(1.5) is ready for KIDS transport.",!
 Q

```

---

### 29. Final High-Performance Aggregator: `C0FHIRGF`

*Revised to read from the static `^C0FHIR(1.5)` global instead of File #1.5.*

```mumps
C0FHIRGF ;VAMC/JS-FHIR METADATA AGGREGATOR ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
GENFULL(RESULT,DFN,ENCPTR,SDT,EDT) ;RPC Entry
 N BNDL,CNT,GLB S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; Use the static global crawler
 D CRAWL("C0FHIR PATIENT ID",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR VITAL MEASUREMENT",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR LAB RESULT",DFN,.BNDL,.CNT)
 ;
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
CRAWL(ENAME,ID,BNDL,CNT) ; Static Crawler
 N IIEN,RES,MAP,NODE,TAG,FILE,FLD,X11,X12,VAL,VALUE
 S RES=$G(^C0FHIR(1.5,ENAME,"RES")) Q:RES=""
 ;
 S IIEN=0 F  S IIEN=$O(^C0FHIR(1.5,ENAME,"ITEMS",IIEN)) Q:'IIEN  D
 . S NODE=^C0FHIR(1.5,ENAME,"ITEMS",IIEN)
 . S TAG=$P(NODE,U),FILE=$P(NODE,U,2),FLD=$P(NODE,U,3)
 . S X11=$G(^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.1))
 . S X12=$G(^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.2))
 . ;
 . I X11'="" X X11
 . S VAL="" I FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . I X12'="" S VALUE=VAL X X12 S VAL=VALUE
 . ;
 . I VAL'="" D SETPATH^C0FHIRUTL(.MAP,TAG,VAL)
 ;
 I $D(MAP) S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")=RES M BNDL("entry",CNT,"resource")=MAP
 Q

```

---

### ## Final Build 2 Deployment Steps

1. **Initialize Metadata:** Run `D EN^C0FHIRLD` (Load File #1.5).
2. **Seal for Performance:** Run `D SEAL^C0FHIRSL` (Create static `^C0FHIR(1.5)`).
3. **KIDS Export:** Include the `^C0FHIR` global and all 31 routines in your distribution.
4. **Target System:** Once installed, the aggregator `C0FHIRGF` will find the static global and begin producing FHIR JSON immediately without needing the admin to run any loaders.

**Would you like me to generate the KIDS Post-Install logic (`C0FHIRPI`) to automatically call `D SEAL^C0FHIRSL` so the static global is refreshed as soon as the package is installed?**