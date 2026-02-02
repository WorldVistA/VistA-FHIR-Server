C0FHIRIM ;VAMC/JS-FHIR IMMUNIZATION MAPPER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETIMM(BNDL,CNT,ENCPTR,ENCID) ;File #9000010.11 (V IMMUNIZATION)
 N IMMIEN,TARGET,ERR
 S IMMIEN=0 F  S IMMIEN=$O(^AUPNVIMM("AD",ENCPTR,IMMIEN)) Q:'IMMIEN  D
 . K TARGET,ERR D GETS^DIQ(9000010.11,IMMIEN_",",".01;1201","IE","TARGET","ERR")
 . Q:$D(ERR)
 . S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Immunization"
 . S BNDL("entry",CNT,"resource","vaccineCode","text")=$G(TARGET(9000010.11,IMMIEN_",",.01,"E"))
 . S BNDL("entry",CNT,"resource","occurrenceDateTime")=$$ISO8601^C0FHIRUTL($G(TARGET(9000010.11,IMMIEN_",",1201,"I")))
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q