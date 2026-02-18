C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER VITALS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,ERR,EIEN
 S EIEN=$O(^DDE("B","C0FHIR VITAL MEASUREMENT",0))
 I 'EIEN W !,"[ERR] Parent Entity 'C0FHIR VITAL MEASUREMENT' not found." Q
 ;
 ; Item: valueQuantity.value
 K FDA,ERR,IEN
 S FDA(1.51,"+1,"_EIEN_",",.01)="valueQuantity.value"
 S FDA(1.51,"+1,"_EIEN_",",.02)=1
 S FDA(1.51,"+1,"_EIEN_",",.04)=120.5,FDA(1.51,"+1,"_EIEN_",",.05)=1.2
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) D EMSG("Vitals Value",.ERR)
 ;
 ; Item: valueQuantity.code
 K FDA,ERR,IEN
 S FDA(1.51,"+1,"_EIEN_",",.01)="valueQuantity.code"
 S FDA(1.51,"+1,"_EIEN_",",.02)=2
 S FDA(1.51,"+1,"_EIEN_",",1.2)="S VALUE=$$GET1^DIQ(120.5,ID,1.2,""E""),VALUE=$P(VALUE,"" "",2) D UCUM^C0FHIRUTL(.VALUE)"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) D EMSG("Vitals UCUM",.ERR)
 Q
 ;
EMSG(TAG,ERR) ; Error display helper
 W !,"[FAIL] "_TAG_": "_$G(ERR("DIERR",1,"TEXT",1))
 Q