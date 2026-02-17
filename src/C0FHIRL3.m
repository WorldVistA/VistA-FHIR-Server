C0FHIRL3 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,EIEN
 S EIEN=$O(^DDE("B","C0FHIR MEDICATION",0)) Q:'EIEN
 ;
 ; Item 1: Medication Reference (RxNorm mapped)
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="medicationCodeableConcept.coding.0.code"
 S FDA(1.51,"+1,"_EIEN_",",1.2)="D RXNORM^C0FHIRRX(.VALUE,ID)"
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: Status Transform
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="status"
 S FDA(1.51,"+2,"_EIEN_",",.04)=100,FDA(1.51,"+2,"_EIEN_",",.05)=5
 S FDA(1.51,"+2,"_EIEN_",",1.2)="S VALUE=$S(VALUE=""dc"":""cancelled"",1:""active"")"
 D UPDATE^DIE("","FDA")
 Q