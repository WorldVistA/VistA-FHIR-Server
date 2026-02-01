C0FHIRMX ;VAMC/JS-FHIR MEDICATION MAPPER ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
GETMEDS(BNDL,CNT,DFN,ENCID) ;Pull Active Meds for Patient
 ; File #52: PRESCRIPTION -> 6:DRUG; 100:STATUS
 N ID,TARGET,ERR,RXN
 S ID=0 F  S ID=$O(^PSRX("B",DFN,ID)) Q:'ID  D
 . K TARGET,ERR
 . D GETS^DIQ(52,ID_",","6;100","IE","TARGET","ERR")
 . Q:$D(ERR)
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")="MedicationStatement"
 . S BNDL("entry",CNT,"resource","status")="active"
 . S BNDL("entry",CNT,"resource","medicationCodeableConcept","text")=$G(TARGET(52,ID_",",6,"E"))
 . ; Lookup RxNorm via Helper
 . S RXN=$$GETRX^C0FHIRRX(ID)
 . I RXN'="" D
 .. S BNDL("entry",CNT,"resource","medicationCodeableConcept","coding",1,"system")="http://www.nlm.nih.gov/research/pim/rxnorm"
 .. S BNDL("entry",CNT,"resource","medicationCodeableConcept","coding",1,"code")=RXN
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q