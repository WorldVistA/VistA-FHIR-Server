C0FHIRPM ;VAMC/JS-FHIR PROCEDURE MAPPER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETPRC(BNDL,CNT,ENCPTR,ENCID) ;File #9000010.18 (V PROCEDURE)
 N PRCIEN,TARGET,ERR
 S PRCIEN=0 F  S PRCIEN=$O(^AUPNVPRC("AD",ENCPTR,PRCIEN)) Q:'PRCIEN  D
 . K TARGET,ERR D GETS^DIQ(9000010.18,PRCIEN_",",".01;1201","IE","TARGET","ERR")
 . Q:$D(ERR)
 . S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Procedure"
 . S BNDL("entry",CNT,"resource","code","text")=$G(TARGET(9000010.18,PRCIEN_",",.01,"E"))
 . S BNDL("entry",CNT,"resource","performedDateTime")=$$ISO8601^C0FHIRUTL($G(TARGET(9000010.18,PRCIEN_",",1201,"I")))
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q