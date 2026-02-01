C0FHIRVM ;VAMC/JS-FHIR VITALS MAPPER ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
GETVIT(BNDL,CNT,DFN,VDT,ENCID) ;Pull Vitals by Date/Time
 ; File #120.5: GMRV VITALS/MEASUREMENTS -> .03:VITAL TYPE; 1.2:RATE; 1201:DATE
 N ID,TARGET,ERR,VTYPE,LOINC
 S ID=0 F  S ID=$O(^GMR(120.5,"B",VDT,ID)) Q:'ID  D
 . K TARGET,ERR
 . D GETS^DIQ(120.5,ID_",",".02;.03;1.2;1201","IE","TARGET","ERR")
 . Q:$G(TARGET(120.5,ID_",",.02,"I"))'=DFN  ; Ensure vital belongs to this patient
 . S VTYPE=$G(TARGET(120.5,ID_",",.03,"E"))
 . S LOINC=$S(VTYPE="BLOOD PRESSURE":"8480-6",VTYPE="HEIGHT":"8302-2",VTYPE="WEIGHT":"29463-7",VTYPE="PULSE":"8867-4",VTYPE="TEMPERATURE":"8310-5",1:"")
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")="Observation"
 . S BNDL("entry",CNT,"resource","category",1,"coding",1,"code")="vital-signs"
 . I LOINC'="" S BNDL("entry",CNT,"resource","code","coding",1,"code")=LOINC,BNDL("entry",CNT,"resource","code","coding",1,"system")="http://loinc.org"
 . S BNDL("entry",CNT,"resource","code","text")=VTYPE
 . S BNDL("entry",CNT,"resource","valueQuantity","value")=$G(TARGET(120.5,ID_",",1.2,"E"))
 . S BNDL("entry",CNT,"resource","effectiveDateTime")=$$ISO8601^C0FHIRUTL($G(TARGET(120.5,ID_",",1201,"I")))
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q