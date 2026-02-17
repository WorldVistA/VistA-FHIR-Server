C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"Loading Administrative Entities (Namespace: C0FHIR, Model: FHIR)..."
 D ADMIN
 W !,"Loading Clinical Partitions..."
 D EN^C0FHIRL1
 D EN^C0FHIRL2
 D EN^C0FHIRL3
 W !!,"Entity Load Complete. Use D EN^C0FHIRVR to verify File #1.5.",!
 Q
 ;
ADMIN ; Load Administrative Resources (Patient, Organization)
 N FDA,IEN,ERR
 ; --- Entity: C0FHIR PATIENT ID ---
 S FDA(1.5,"+1,",.01)="C0FHIR PATIENT ID"
 S FDA(1.5,"+1,",.02)=2 ; File #2
 S FDA(1.5,"+1,",.04)="Patient" ; FHIR Resource Name
 S FDA(1.5,"+1,",1)="FHIR" ; Data Model
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="SSN"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1
 . S FDA(1.51,"+2,"_IEN(1)_",",.03)="ENTITY"
 . S FDA(1.51,"+2,"_IEN(1)_",",.04)=2
 . S FDA(1.51,"+2,"_IEN(1)_",",.05)=.09
 . S FDA(1.51,"+2,"_IEN(1)_",",1.2)="S VALUE=VALUE_""^SSN^^SSA"""
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity: C0FHIR FACILITY ---
 K FDA,IEN S FDA(1.5,"+1,",.01)="C0FHIR FACILITY"
 S FDA(1.5,"+1,",.02)=4 ; File #4
 S FDA(1.5,"+1,",.04)="Organization"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 Q
 ;
CLEAN ; Only clear the C0FHIR namespace to preserve VPR entities
 N DIK,DA,NAME
 S NAME="C0FHIR" F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q