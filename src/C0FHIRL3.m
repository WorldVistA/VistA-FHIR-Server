C0FHIRL3 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,ERR,EIEN
 S EIEN=$O(^DDE("B","C0FHIR MEDICATION",0)) Q:'EIEN
 ;
 K FDA,ERR S FDA(1.51,"+1,"_EIEN_",",.01)="status"
 S FDA(1.51,"+1,"_EIEN_",",.04)=100,FDA(1.51,"+1,"_EIEN_",",.05)=5
 S FDA(1.51,"+1,"_EIEN_",",1.2)="S VALUE=$S(VALUE=""dc"":""cancelled"",1:""active"")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"[FAIL] Med Status: ",$G(ERR("DIERR",1,"TEXT",1))
 Q