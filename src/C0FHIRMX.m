C0FHIRMX ;VAMC/JS-FHIR MEDICATION MAPPER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETMEDS(BNDL,CNT,DFN,ENCID) ;File #52 (PRESCRIPTION)
 N ID,TARGET,ERR,RXN
 S ID=0 F  S ID=$O(^PSRX("C",DFN,ID)) Q:'ID  D
 . K TARGET,ERR D GETS^DIQ(52,ID_",","6;100","IE","TARGET","ERR")
 . Q:$D(ERR)
 . S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="MedicationStatement"
 . S BNDL("entry",CNT,"resource","status")="active"
 . S BNDL("entry",CNT,"resource","medicationCodeableConcept","text")=$G(TARGET(52,ID_",",6,"E"))
 . S RXN=$$GETRX^C0FHIRRX(ID)
 . I RXN'="" S BNDL("entry",CNT,"resource","medicationCodeableConcept","coding",1,"code")=RXN
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q