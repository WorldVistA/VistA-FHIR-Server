C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER VITALS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; Called by Master Loader
 N FDA,IEN,ERR,EIEN
 S EIEN=$O(^DDE("B","C0FHIR VITAL MEASUREMENT",0)) Q:'EIEN
 ;
 ; Item 1: The Numerical Value (Direct FileMan Mapping)
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="valueQuantity.value"
 S FDA(1.51,"+1,"_EIEN_",",.02)=1 ; Sequence
 S FDA(1.51,"+1,"_EIEN_",",.04)=120.5 ; Source File
 S FDA(1.51,"+1,"_EIEN_",",.05)=1.2 ; Source Field (Rate/Reading)
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: The UCUM Unit Code (Transform Logic)
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="valueQuantity.code"
 S FDA(1.51,"+2,"_EIEN_",",.02)=2
 S FDA(1.51,"+2,"_EIEN_",",1.2)="S VALUE=$$GET1^DIQ(120.5,ID,1.2,""E""),VALUE=$P(VALUE,"" "",2) D UCUM^C0FHIRUTL(.VALUE)"
 D UPDATE^DIE("","FDA")
 ;
 ; Item 3: Effective Date (ISO8601 Transform)
 K FDA S FDA(1.51,"+3,"_EIEN_",",.01)="effectiveDateTime"
 S FDA(1.51,"+3,"_EIEN_",",.02)=3
 S FDA(1.51,"+3,"_EIEN_",",.04)=120.5,FDA(1.51,"+3,"_EIEN_",",.05)=.01
 S FDA(1.51,"+3,"_EIEN_",",1.2)="S VALUE=$$DATE^C0FHIRUTL(VALUE)"
 D UPDATE^DIE("","FDA")
 Q