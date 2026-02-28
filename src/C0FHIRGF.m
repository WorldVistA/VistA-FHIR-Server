C0FHIRGF ;VAMC/JS-FHIR NATIVE DDE WRAPPER ; 21-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 21, 2026;Build 2
 Q
 ;
GENFULL(RESULT,DFN) ; Generate a full FHIR Patient Bundle using ^DDE metadata
 ; Input: DFN - Patient IEN (File #2)
 ; Output: RESULT - Array containing JSON lines (for XLFJSON)
 ; Uses ^DDE entity registry directly (metadata-driven extraction)
 ;
 N BNDL,CNT,GLB,ENTITY
 S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 1. Initialize VistA environment
 D DT^DICRW
 ;
 ; 2. Extract entities from ^DDE registry (matches C0FHIRLD loader)
 ; Entity names must match what C0FHIRLD creates
 D CRAWL("C0FHIR PATIENT ID",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR VITAL MEASUREMENT",DFN,.BNDL,.CNT)
 D CRAWL("C0FHIR LAB RESULT",DFN,.BNDL,.CNT)
 ;
 ; 3. Encode to JSON
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
CRAWL(ENAME,ID,BNDL,CNT) ; Crawl ^DDE entity metadata and build FHIR resource
 ; Reads entity definitions from ^DDE (File #1.5 / DDE registry)
 ; Executes GET ACTION (1.1), fetches data, runs DATA TRANSFORM (1.2)
 ;
 N EIEN,IIEN,TAG,FILE,FLD,X6,X4,VAL,VALUE,RES,MAP,ITEM,DIEN
 S DIEN=ID
 S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 ;
 ; Resource type: from ^DDE(EIEN,0) piece 5, or File 1.5 .04
 S RES=$P($G(^DDE(EIEN,0)),U,5)
 I RES="" S RES=$$GET1^DIQ(1.5,EIEN_",",.04)
 I RES="" S RES="Resource"
 ;
 ; Fallback: C0FHIR PATIENT ID has no items in loader - use C0FHIRPT
 I ENAME="C0FHIR PATIENT ID",'$O(^DDE(EIEN,1,0)) D GETPT^C0FHIRPT(.BNDL,.CNT,ID) Q
 ;
 ; Loop through ITEM multiple (#1.51). DDE: 6=GET ACTION, 4=OUTPUT TRANSFORM
 S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 . S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 . S TAG=$P(ITEM,U)
 . S FILE=+$P(ITEM,U,4),FLD=$P(ITEM,U,5)
 . ;
 . ; A. Execute GET ACTION (field 6) - can set VALUE for transform-only items
 . S X6=$G(^DDE(EIEN,1,IIEN,6)) I X6'="" X X6
 . ;
 . ; B. Fetch value from FileMan if not set by GET ACTION
 . I $G(VALUE)="" S VAL=""
 . I $G(VALUE)="",FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . I $G(VALUE)'="" S VAL=VALUE
 . ;
 . ; C. Execute OUTPUT TRANSFORM (field 4)
 . S X4=$G(^DDE(EIEN,1,IIEN,4)) I X4'="" S VALUE=VAL X X4 S VAL=VALUE
 . ;
 . ; D. Map into JSON structure
 . I $G(VAL)'="" D SETPATH^C0FHIRUTL(.MAP,TAG,VAL)
 . K VALUE
 ;
 ; Add resource to bundle
 I $D(MAP) D
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")=RES
 . M BNDL("entry",CNT,"resource")=MAP
 Q
 ;
TEST(DFN) ; Manual Test Entry Point
 N RES,I S DFN=$G(DFN) I 'DFN Q
 W !!,"Requesting DDE Metadata Extraction for DFN: ",DFN
 D GENFULL(.RES,DFN)
 ;
 I '$D(RES) W !,"No data returned." Q
 ;
 W !!,"--- FHIR Bundle Output ---",!
 S I=0 F  S I=$O(RES(I)) Q:'I  W !,RES(I)
 W !,"------------------------------",!
 Q
