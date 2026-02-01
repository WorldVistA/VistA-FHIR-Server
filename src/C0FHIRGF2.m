C0FHIRGF ;VAMC/JS-FHIR MASTER AGGREGATOR ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
GENFULL(RESULT,DFN,ENCPTR) ;RPC: C0FHIR GET FULL BUNDLE
 N BNDL,CNT,GLB,LRDFN,ENCID,VDT,VISIT,TARGET,ERR
 S CNT=0,GLB=$NA(^TMP("C0FHIRGF",$J)) K @GLB,RESULT
 ;
 ; 1. Initialize Bundle
 S BNDL("resourceType")="Bundle",BNDL("type")="collection"
 ;
 ; 2. Get Patient & Lab Pointer (Module: PT)
 S LRDFN=$$GETPT^C0FHIRPT(.BNDL,.CNT,DFN)
 ;
 ; 3. Get Encounter Context (File #409.68: OUTPATIENT ENCOUNTER)
 S ENCID="ENC-"_ENCPTR
 K TARGET,ERR D GETS^DIQ(409.68,ENCPTR_",",".01;.05","IE","TARGET","ERR")
 I $D(ERR) D LOGERR^C0FHIRGF("Encounter Lookup",.ERR,.BNDL,.CNT) G EXIT
 S VDT=$G(TARGET(409.68,ENCPTR_",",.01,"I"))
 S VISIT=$G(TARGET(409.68,ENCPTR_",",.05,"I"))
 ; Add Encounter Resource to Bundle
 S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Encounter"
 S BNDL("entry",CNT,"resource","id")=ENCID
 S BNDL("entry",CNT,"resource","subject","reference")="Patient/"_DFN
 ;
 ; 4. Call Clinical Modules (The "Rest of Them")
 D GETLAB^C0FHIRLM(.BNDL,.CNT,LRDFN,VISIT,ENCID) ; Lab Module
 D GETIMM^C0FHIRIM(.BNDL,.CNT,ENCPTR,ENCID)     ; Immunization Module
 D GETVIT^C0FHIRVM(.BNDL,.CNT,DFN,VDT,ENCID)    ; Vitals Module
 D GETMEDS^C0FHIRMX(.BNDL,.CNT,DFN,ENCID)       ; Meds Module
 D GETPRC^C0FHIRPM(.BNDL,.CNT,ENCPTR,ENCID)     ; Procedures Module
 ;
EXIT ; Wrap up
 S BNDL("total")=CNT
 D ENCODE^XLFJSON("BNDL",GLB)
 M RESULT=@GLB
 K @GLB
 Q