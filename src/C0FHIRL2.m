C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY & LAB ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Entry point called by Master Loader
 N FDA,IEN,ERR
 ;
 ; --- Entity #56: FHIR MEDICATION ---
 S FDA(1.1,"+1,",.01)="FHIR MEDICATION"
 S FDA(1.1,"+1,",.02)=100 ; File #100 (Orders)
 S FDA(1.1,"+1,",.04)="Medication"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="Status"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=15
 . S FDA(1.11,"+2,"_IEN(1)_",",1.2)="N X S X=VALUE,VALUE=$S(X=""dc"":""D"",X=""canc"":""C"",1:""IP"")"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #13: FHIR LAB ORDER ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="FHIR LAB ORDER"
 S FDA(1.1,"+1,",.02)=100
 S FDA(1.1,"+1,",.04)="LabOrder"
 S FDA(1.1,"+1,",1)="FHIR"
 ; Complex "Get Entry Action" logic from your report
 S FDA(1.1,IEN(1)_",",1.1)="S:'DFN&ID DFN=+$P($G(^OR(100,ID,0)),U,2) S LRDFN=+$G(^DPT(DFN,""LR""))"
 D UPDATE^DIE("","FDA","IEN")
 ;
 ; --- Entity #17: FHIR LRCH RESULT ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="FHIR LRCH RESULT"
 S FDA(1.1,"+1,",.02)=63.04 ; Chemistry sub-file
 S FDA(1.1,"+1,",.04)="Result"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 Q