C0FHIRGF ;VAMC/JS-FHIR MASTER AGGREGATOR ; 30-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 30, 2026;Build 1
 Q
GENFULL(RESULT,DFN,ENCPTR) ;RPC: C0FHIR GET FULL BUNDLE
 N BNDL,CNT,GLB,LRDFN,ENCID,VDT,VISIT,TARGET,ERR,CURREENC
 S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 1. Get Patient Header (Module: PT)
 S LRDFN=$$GETPT^C0FHIRPT(.BNDL,.CNT,DFN)
 ;
 ; 2. Determine Processing Mode (Single vs Bulk)
 I +ENCPTR D
 . D PROC(ENCPTR,.BNDL,.CNT,DFN,LRDFN)
 E  D
 . ; Loop through "C" index: ^SCE("C", PntPtr, EncPtr)
 . S CURRENC=0 F  S CURRENC=$O(^SCE("C",DFN,CURRENC)) Q:'CURRENC  D
 .. D PROC(CURRENC,.BNDL,.CNT,DFN,LRDFN)
 ;
EXIT ; Wrap up
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB
 K @GLB
 Q
 ;
PROC(IE,BNDL,CNT,DFN,LRDFN) ; Internal Processing Logic for one encounter
 N VDT,VISIT,ENCID,TARGET,ERR
 S ENCID="ENC-"_IE
 K TARGET,ERR D GETS^DIQ(409.68,IE_",",".01;.05","IE","TARGET","ERR")
 I $D(ERR) Q  ; Skip bad encounter records
 S VDT=$G(TARGET(409.68,IE_",",.01,"I"))
 S VISIT=$G(TARGET(409.68,IE_",",.05,"I"))
 ;
 ; Add Encounter Resource
 S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Encounter"
 S BNDL("entry",CNT,"resource","id")=ENCID
 S BNDL("entry",CNT,"resource","subject","reference")="Patient/"_DFN
 ;
 ; Call Clinical Modules
 D GETLAB^C0FHIRLM(.BNDL,.CNT,LRDFN,VISIT,ENCID)
 D GETIMM^C0FHIRIM(.BNDL,.CNT,IE,ENCID)
 D GETVIT^C0FHIRVM(.BNDL,.CNT,DFN,VDT,ENCID)
 D GETMEDS^C0FHIRMX(.BNDL,.CNT,DFN,ENCID)
 D GETPRC^C0FHIRPM(.BNDL,.CNT,IE,ENCID)
 Q