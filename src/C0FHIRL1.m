C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER VITALS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,ERR,EIEN
 S EIEN=$O(^DDE("B","C0FHIR VITAL MEASUREMENT",0)) Q:'EIEN
 ;
 ; Use Field #2 (standard for MUMPS code in many DDE versions)
 K FDA,ERR S FDA(1.51,"+1,"_EIEN_",",.01)="valueQuantity.code"
 S FDA(1.51,"+1,"_EIEN_",",.02)=2
 S FDA(1.51,"+1,"_EIEN_",",2)="S VALUE=$$GET1^DIQ(120.5,ID,1.2,""E""),VALUE=$P(VALUE,"" "",2) D UCUM^C0FHIRUTL(.VALUE)"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"[FAIL] Vitals Transform (Fld 2): ",$G(ERR("DIERR",1,"TEXT",1))
 Q