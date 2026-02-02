C0FHIRPT ;VAMC/JS-FHIR PATIENT UTILITY ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETPT(BNDL,CNT,DFN) ;Extract Patient Demographics (File #2: PATIENT)
 N TARGET,ERR
 D GETS^DIQ(2,DFN_",",".01;.02;.03;.09;.115;.63","IE","TARGET","ERR")
 I $D(ERR) Q 0
 S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Patient"
 S BNDL("entry",CNT,"resource","id")=DFN
 S BNDL("entry",CNT,"resource","name",1,"text")=$G(TARGET(2,DFN_",",.01,"E"))
 S BNDL("entry",CNT,"resource","gender")=$S($G(TARGET(2,DFN_",",.02,"I"))="M":"male",1:"female")
 S BNDL("entry",CNT,"resource","birthDate")=$$ISO8601^C0FHIRUTL($G(TARGET(2,DFN_",",.03,"I")))
 S BNDL("entry",CNT,"resource","address",1,"state")=$G(TARGET(2,DFN_",",.115,"E"))
 Q $G(TARGET(2,DFN_",",.63,"I")) ; Return LRDFN