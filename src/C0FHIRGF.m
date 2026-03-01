C0FHIRGF ;VAMC/JS-FHIR MASTER AGGREGATOR ; 23-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 23, 2026;Build 3
 Q
 ;
GENFULL(RESULT,DFN,ENCPTR,SDT,EDT) ;RPC: C0FHIR GET FULL BUNDLE
 ; Encounter-centric: one encounter, all encounters, or date range
 ; DFN=Patient IEN, ENCPTR=single encounter (409.68), SDT/EDT=date range
 ;
 N BNDL,CNT,GLB,LRDFN,ENCID,VISIT,CURRENC,EDTM,CDT,TARGET,ERR
 S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 ;
 ; 1. Initialize Bundle
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 2. Get Patient (Module: PT)
 S LRDFN=$$GETPT^C0FHIRPT(.BNDL,.CNT,DFN)
 ;
 ; 3. Determine Mode: Single Encounter vs Date Range
 D DT^DICRW
 I $G(EDT)="" S EDT=$$NOW^XLFDT
 ;
 I +ENCPTR D
 . D PROC(ENCPTR,.BNDL,.CNT,DFN,LRDFN)
 E  D
 . S SDT=$G(SDT,0),EDT=$G(EDT,9999999),EDTM=EDT_".9999"
 . S CDT=SDT-.000001
 . F  S CDT=$O(^SCE("ADFN",DFN,CDT)) Q:'CDT!(CDT>EDTM)  D
 .. S CURRENC=0 F  S CURRENC=$O(^SCE("ADFN",DFN,CDT,CURRENC)) Q:'CURRENC  D
 ... D PROC(CURRENC,.BNDL,.CNT,DFN,LRDFN)
 ;
EXIT
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB K @GLB
 Q
 ;
PROC(IE,BNDL,CNT,DFN,LRDFN) ; Process one encounter + related resources
 ; IE = File #409.68 (OUTPATIENT ENCOUNTER) IEN
 N VDT,VISIT,ENCID,TARGET,ERR
 K TARGET,ERR D GETS^DIQ(409.68,IE_",",".01;.05","IE","TARGET","ERR")
 I $D(ERR) D LOGERR("Encounter Lookup",.ERR,.BNDL,.CNT) Q
 S VDT=$G(TARGET(409.68,IE_",",.01,"I")),VISIT=$G(TARGET(409.68,IE_",",.05,"I"))
 S ENCID="Encounter-"_VISIT
 ;
 ; Add Encounter via DDE (C0FHIR ENCOUNTER) or minimal stub
 I $O(^DDE("B","C0FHIR ENCOUNTER",0)) D
 . D CRAWL("C0FHIR ENCOUNTER",VISIT,.BNDL,.CNT)
 E  D
 . S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Encounter"
 . S BNDL("entry",CNT,"resource","id")=ENCID
 . S BNDL("entry",CNT,"resource","subject","reference")="Patient/"_DFN
 ;
 ; Clinical modules (encounter-scoped)
 D GETLAB^C0FHIRLM(.BNDL,.CNT,LRDFN,VISIT,ENCID)
 D GETIMM^C0FHIRIM(.BNDL,.CNT,IE,ENCID)
 D GETVIT^C0FHIRVM(.BNDL,.CNT,DFN,VDT,ENCID)
 D GETMEDS^C0FHIRMX(.BNDL,.CNT,DFN,ENCID)
 D GETPRC^C0FHIRPM(.BNDL,.CNT,IE,ENCID)
 Q
 ;
CRAWL(ENAME,ID,BNDL,CNT) ; Crawl ^DDE entity metadata and build FHIR resource
 N EIEN,IIEN,TAG,FILE,FLD,X6,X4,VAL,VALUE,RES,MAP,ITEM,DIEN
 S DIEN=ID
 S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 ;
 S RES=$P($G(^DDE(EIEN,0)),U,5)
 I RES="" S RES=$$GET1^DIQ(1.5,EIEN_",",.04)
 I RES="" S RES="Resource"
 ;
 I ENAME="C0FHIR PATIENT ID",'$O(^DDE(EIEN,1,0)) D GETPT^C0FHIRPT(.BNDL,.CNT,ID) Q
 ;
 S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 . S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 . S TAG=$P(ITEM,U)
 . S FILE=+$P(ITEM,U,4),FLD=$P(ITEM,U,5)
 . S X6=$G(^DDE(EIEN,1,IIEN,6)) I X6'="" X X6
 . I $G(VALUE)="" S VAL=""
 . I $G(VALUE)="",FILE,FLD S VAL=$$GET1^DIQ(FILE,ID_",",FLD,"I")
 . I $G(VALUE)'="" S VAL=VALUE
 . S X4=$G(^DDE(EIEN,1,IIEN,4)) I X4'="" S VALUE=VAL X X4 S VAL=VALUE
 . I $G(VAL)'="" D SETPATH^C0FHIRUTL(.MAP,TAG,VAL)
 . K VALUE
 ;
 I $D(MAP) D
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")=RES
 . M BNDL("entry",CNT,"resource")=MAP
 Q
 ;
LOGERR(MSG,ERR,BNDL,CNT) ; Log FileMan errors as FHIR OperationOutcome
 N DIAG S DIAG=$G(ERR("DIERR",1,"TEXT",1))
 D LOGERR2(MSG,DIAG,.BNDL,.CNT)
 Q
 ;
LOGERR2(MSG,DIAG,BNDL,CNT) ; Log custom diagnostic (used by C0FHIRWS)
 S CNT=CNT+1
 S BNDL("entry",CNT,"resource","resourceType")="OperationOutcome"
 S BNDL("entry",CNT,"resource","issue",1,"severity")="error"
 S BNDL("entry",CNT,"resource","issue",1,"diagnostics")="VistA Error in "_MSG_$S($G(DIAG)'="":": "_DIAG,1:"")
 Q
 ;
TEST(DFN) ; Manual Test: Single patient, all encounters in date range
 N RES,I S DFN=$G(DFN) I 'DFN Q
 W !!,"Requesting FHIR Bundle for DFN: ",DFN," (all encounters)..."
 D GENFULL(.RES,DFN,"","","")
 I '$D(RES) W !,"No data returned." Q
 W !!,"--- FHIR Bundle Output ---",!
 S I=0 F  S I=$O(RES(I)) Q:'I  W !,RES(I)
 W !,"------------------------------",!
 Q
