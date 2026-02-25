To implement a fully metadata-driven approach that bypasses the `^DDE` execution engine while handling the structural complexity of FHIR (like `Coding`, `Quantity`, and `Reference` objects), we need a more sophisticated `PROCESS` loop.

I have updated **`C0FHIRGF`** to act as a recursive metadata parser. It now interprets the **Item Multiple (#1.51)** not just as flat fields, but as a blueprint for building the nested JSON objects required by FHIR.

### 29. Metadata Crawler: `C0FHIRGF`

*Bypasses `^DDE` engine; uses File #1.5 as a structural map.*

```mumps
C0FHIRGF ;VAMC/JS-FHIR METADATA AGGREGATOR ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
GENFULL(RESULT,DFN,ENCPTR,SDT,EDT) ;RPC: C0FHIR GET FULL BUNDLE
 N BNDL,CNT,GLB S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 1. Map Core Entities via File #1.5 Metadata
 D CRAWL("C0FHIR PATIENT ID",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR VITAL MEASUREMENT",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR LAB RESULT",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR MEDICATION",DFN,.BNDL,.CNT)
 ;
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
CRAWL(ENAME,ID,BNDL,CNT) ; Crawl File #1.5 and manually construct JSON
 N EIEN,IIEN,TAG,FLD,FILE,XEC,VAL,RES,MAP,ITEM
 S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 S RES=$$GET1^DIQ(1.5,EIEN_",",.04) ; Resource Type (e.g., Observation)
 ;
 ; Loop through ITEM Multiple (#1.51)
 S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 . S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 . S TAG=$P(ITEM,U) ; The FHIR path (e.g., "code.coding.0.code")
 . S FILE=$P(ITEM,U,4),FLD=$P(ITEM,U,5)
 . ;
 . ; A. Execute "GET ACTION" (Init context/variables)
 . S XEC=$G(^DDE(EIEN,1,IIEN,1)) I XEC'="" X XEC
 . ;
 . ; B. Fetch Value
 . S VAL="" I FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . ;
 . ; C. Execute "DATA TRANSFORM"
 . S XEC=$G(^DDE(EIEN,1,IIEN,1.2)) I XEC'="" S VALUE=VAL X XEC S VAL=VALUE
 . ;
 . ; D. Map into JSON structure manually
 . I VAL'="" D SETPATH(.MAP,TAG,VAL)
 ;
 ; Add the populated resource to the bundle
 I $D(MAP) D
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")=RES
 . M BNDL("entry",CNT,"resource")=MAP
 Q
 ;
SETPATH(ARR,PATH,VAL) ; Helper to build nested JSON arrays from dot-notation
 N I,P,REF
 S REF="ARR"
 F I=1:1:$L(PATH,".") S P=$P(PATH,".",I) D
 . I P=+P S REF=REF_"("_P_")" ; Handle numeric array indices
 . E  S REF=REF_"("""_P_""")"
 S @REF=VAL
 Q

```

---

### ## Handling the WKLD/LOINC Logic in Metadata

Since the crawler executes the **Data Transform** field directly, your loader (`C0FHIRL2`) must store the "Site  WKLD  LOINC" logic as a snippet of M code inside **Field #1.2**.

### 24. Updated Lab Loader: `C0FHIRL2`

*Configures the metadata to support the manual crawler.*

```mumps
C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY & LAB ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ;
 N FDA,IEN,LN
 ; Path to LOINC from File #60 Result
 S LN="N W,S S S=$O(^LAB(60,ID,1,0)),W=$$GET1^DIQ(60.01,S_"",""_ID_"","",2,""I""),VALUE=$$GET1^DIQ(64,W,25)"
 ;
 ; --- Entity: C0FHIR LAB RESULT ---
 S FDA(1.5,"+1,",.01)="C0FHIR LAB RESULT"
 S FDA(1.5,"+1,",.02)=63.04
 S FDA(1.5,"+1,",.04)="Observation"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . ; Item 1: The LOINC Code
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="code.coding.0.code"
 . S FDA(1.51,"+2,"_IEN(1)_",",1.2)=LN
 . D UPDATE^DIE("","FDA")
 . ; Item 2: The System
 . K FDA S FDA(1.51,"+3,"_IEN(1)_",",.01)="code.coding.0.system"
 . S FDA(1.51,"+3,"_IEN(1)_",",1.2)="S VALUE=""http://loinc.org"""
 . D UPDATE^DIE("","FDA")
 Q

```

---

### ## Why this Metadata Crawler is superior for your needs:

1. **Dot-Notation Support:** By using the `SETPATH` helper, you can define complex FHIR paths like `code.coding.0.display` directly in the **File #1.5** metadata. The crawler will automatically build the nested JSON structure.
2. **Explicit Control:** You are no longer reliant on how `^DDE` handles its internal loops. If you want to change how a Lab result is formatted, you only change the metadata; `C0FHIRGF` remains generic.
3. **Performance:** By bypassing the full DDE engine, you eliminate overhead for simple extractions while maintaining the flexibility of a metadata-driven architecture.

**Would you like me to update the `C0FHIRL1` loader for Vitals to use this same dot-notation metadata for the `valueQuantity` and `unit` fields?**