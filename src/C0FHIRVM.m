C0FHIRVM ;VAMC/JS-FHIR VITALS MAPPER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETVIT(BNDL,CNT,DFN,VDT,ENCID) ;File #120.5 (GMRV VITALS/MEASUREMENTS)
 N ID,TARGET,ERR,VTYPE,LOINC
 S ID=0 F  S ID=$O(^GMR(120.5,"B",VDT,ID)) Q:'ID  D
 . K TARGET,ERR D GETS^DIQ(120.5,ID_",",".02;.03;1.2;1201","IE","TARGET","ERR")
 . Q:$G(TARGET(120.5,ID_",",.02,"I"))'=DFN
 . S VTYPE=$G(TARGET(120.5,ID_",",.03,"E"))
 . S LOINC=$S(VTYPE="BLOOD PRESSURE":"8480-6",VTYPE="HEIGHT":"8302-2",VTYPE="WEIGHT":"29463-7",1:"")
 . S CNT=CNT+1,BNDL("entry",CNT,"resource","resourceType")="Observation"
 . S BNDL("entry",CNT,"resource","category",1,"coding",1,"code")="vital-signs"
 . S BNDL("entry",CNT,"resource","code","text")=VTYPE
 . S BNDL("entry",CNT,"resource","valueQuantity","value")=$G(TARGET(120.5,ID_",",1.2,"E"))
 . S BNDL("entry",CNT,"resource","effectiveDateTime")=$$ISO8601^C0FHIRUTL($G(TARGET(120.5,ID_",",1201,"I")))
 . S BNDL("entry",CNT,"resource","encounter","reference")="Encounter/"_ENCID
 Q