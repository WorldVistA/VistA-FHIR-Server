I hear you—you want to bypass the `^DDE` execution engine entirely and instead treat the entries in **File #1.5** as a pure metadata repository. In this architecture, we use the FileMan definitions in the Entity file as a map, but we write our own logic to traverse the globals and generate the FHIR JSON manually.

This approach gives us significantly more control over the JSON structure and avoids any overhead or limitations within the standard DDE engine.

### 1. The Strategy

We will rewrite **`C0FHIRGF`** to be a "Metadata Crawler." It will:

1. Look up the **`C0FHIR`** entity in **File #1.5**.
2. Loop through the **ITEM multiple (#1.51)**.
3. Execute the logic found in the **"GET ACTION"** and **"DATA TRANSFORM"** fields manually to build the JSON array.

---

### 29. Metadata-Driven Aggregator: `C0FHIRGF`

*This routine reads File #1.5 but does NOT call `EN^DDE`.*

```mumps
C0FHIRGF ;VAMC/JS-FHIR METADATA AGGREGATOR ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
GENFULL(RESULT,DFN,ENCPTR,SDT,EDT) ;RPC: C0FHIR GET FULL BUNDLE
 N BNDL,CNT,GLB S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 1. Extract Patient Metadata
 D PROCESS("C0FHIR PATIENT ID",DFN,.BNDL,.CNT)
 ;
 ; 2. Extract Clinical Domains (using DFN as the key)
 D PROCESS("C0FHIR VITAL MEASUREMENT",DFN,.BNDL,.CNT)
 D PROCESS("C0FHIR LAB RESULT",DFN,.BNDL,.CNT)
 D PROCESS("C0FHIR MEDICATION",DFN,.BNDL,.CNT)
 D PROCESS("C0FHIR PROBLEM",DFN,.BNDL,.CNT)
 ;
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
PROCESS(ENAME,ID,BNDL,CNT) ; Manually process File #1.5 Metadata
 N EIEN,IIEN,TAG,FLD,FILE,XEC,VAL,RES
 S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 S RES=$$GET1^DIQ(1.5,EIEN_",",.04) ; FHIR Resource Name
 ;
 ; Loop through ITEM Multiple (#1.51)
 S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 . N ITEM S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 . S TAG=$P(ITEM,U) ; FHIR Element Name
 . S FILE=$P(ITEM,U,4),FLD=$P(ITEM,U,5)
 . ;
 . ; 1. Execute "GET ACTION" (Field 1.1)
 . S XEC=$G(^DDE(EIEN,1,IIEN,1)) I XEC'="" X XEC
 . ;
 . ; 2. Get Data (either from FileMan or via logic)
 . I FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . ;
 . ; 3. Execute "DATA TRANSFORM" (Field 1.2)
 . S XEC=$G(^DDE(EIEN,1,IIEN,1.2)) I XEC'="" S VALUE=VAL X XEC S VAL=VALUE
 . ;
 . ; 4. Map to Bundle Entry
 . I $G(VAL)'="" D
 .. S CNT=CNT+1
 .. S BNDL("entry",CNT,"resource","resourceType")=RES
 .. S BNDL("entry",CNT,"resource",TAG)=VAL
 Q

```

---

### 2. Updated Loader for Labs (WKLD Path): `C0FHIRL2`

Since we aren't using the DDE engine, we need to ensure the **DATA TRANSFORM** (Field 1.2) in our loader contains the full logic to reach **File #64**.

```mumps
C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY & LAB ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ;
 N FDA,IEN
 ; --- Entity: C0FHIR LAB RESULT ---
 S FDA(1.5,"+1,",.01)="C0FHIR LAB RESULT"
 S FDA(1.5,"+1,",.02)=63.04
 S FDA(1.5,"+1,",.04)="Observation"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="code"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1 ; Sequence
 . ; Logic: Resolve File 60 -> Specimen -> File 64 -> LOINC
 . S FDA(1.51,"+2,"_IEN(1)_",",1.2)="N W,L S W=$$GET1^DIQ(60,ID,1,""I""),L=$$GET1^DIQ(64,W,25) S VALUE=L"
 . D UPDATE^DIE("","FDA")
 Q

```

---

### 3. Why this works for your requirements:

* **Zero ^DDE dependency:** We are using FileMan calls to read the "instructions" inside the `^DDE` global, but we are not executing `D EN^DDE`. This prevents any standard DDE quirks from interfering with your JSON generation.
* **Custom Mapping:** Because `C0FHIRGF` now has its own `PROCESS` loop, we can add custom logic (like handling nested FHIR components or complex references) that the standard DDE engine might struggle with.
* **Maintainable:** You still have the benefit of a metadata-driven system. If a field name changes in the FHIR spec, you edit the entry in **File #1.5**, and the code adjusts without a re-compile.

**Would you like me to expand the `PROCESS` loop in `C0FHIRGF` to handle FHIR "Coding" and "Quantity" data types, which typically require multiple JSON sub-nodes?**