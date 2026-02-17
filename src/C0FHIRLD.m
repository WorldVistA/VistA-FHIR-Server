C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 W !,"Loading Administrative..." D ADMIN
 W !,"Loading Vitals..." D EN^C0FHIRL1
 W !,"Loading Labs..." D EN^C0FHIRL2
 W !,"Loading Pharmacy..." D EN^C0FHIRL3
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
ADMIN ; Core Patient/Organization Metadata
 N FDA,IEN S FDA(1.5,"+1,",.01)="C0FHIR PATIENT ID"
 S FDA(1.5,"+1,",.02)=2,FDA(1.5,"+1,",.04)="Patient",FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="identifier.0.value"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1,FDA(1.51,"+2,"_IEN(1)_",",.04)=2,FDA(1.51,"+2,"_IEN(1)_",",.05)=.09
 . D UPDATE^DIE("","FDA")
 Q
 ;
CLEAN ; Safely clear only the C0FHIR namespace
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q