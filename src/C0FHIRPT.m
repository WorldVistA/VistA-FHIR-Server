C0FHIRPT ;VAMC/JS-FHIR PATIENT UTILITY ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
GETPT(BNDL,CNT,DFN) ;Extract Patient Demographics
 ; File #2: PATIENT -> .01:NAME; .02:SEX; .03:DOB; .09:SSN; .63:LRDFN
 N TARGET,ERR
 K TARGET,ERR
 D GETS^DIQ(2,DFN_",",".01;.02;.03;.09;.63","IE","TARGET","ERR")
 I $D(ERR) Q 0
 S CNT=CNT+1
 S BNDL("entry",CNT,"resource","resourceType")="Patient"
 S BNDL("entry",CNT,"resource","id")=DFN
 S BNDL("entry",CNT,"resource","name",1,"text")=$G(TARGET(2,DFN_",",.01,"E"))
 S BNDL("entry",CNT,"resource","gender")=$S($G(TARGET(2,DFN_",",.02,"I"))="M":"male",1:"female")
 S BNDL("entry",CNT,"resource","birthDate")=$$ISO8601^C0FHIRUTL($G(TARGET(2,DFN_",",.03,"I")))
 Q $G(TARGET(2,DFN_",",.63,"I")) ; Return LRDFN for Lab use