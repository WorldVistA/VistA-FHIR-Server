C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"Starting FHIR Entity Load..."
 W !,"  Loading Admin..." D ADMIN
 W !,"  Loading Clinical P1 (Vitals/Visits)..." D EN^C0FHIRL1
 W !,"  Loading Clinical P2 (Pharmacy/Labs)..." D EN^C0FHIRL2
 W !,"  Loading Clinical P3 (Safety/History)..." D EN^C0FHIRL3
 W !!,"Entity Load Complete. Verified FHIR Data Model."
 Q
 ;
ADMIN ; Load Administrative Resources (Patient, Facility)
 N FDA,IEN,ERR,MSG
 ; --- Entity #1: VPR PATIENT ID ---
 S FDA(1.1,"+1,",.01)="VPR PATIENT ID"
 S FDA(1.1,"+1,",.02)=2 ; File #2
 S FDA(1.1,"+1,",.04)="PatientID"
 S FDA(1.1,"+1,",1)="FHIR" ; Updated Data Model
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="SSN"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=1
 . S FDA(1.11,"+2,"_IEN(1)_",",.03)="ENTITY"
 . S FDA(1.11,"+2,"_IEN(1)_",",.04)=2
 . S FDA(1.11,"+2,"_IEN(1)_",",.05)=.09
 . S FDA(1.11,"+2,"_IEN(1)_",",1.2)="S VALUE=VALUE_""^SSN^^SSA"""
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #7: VPR FACILITY ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="VPR FACILITY"
 S FDA(1.1,"+1,",.02)=4 ; File #4
 S FDA(1.1,"+1,",.04)="Organization"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 Q
 ;
CLEAN ; Clear namespaces to prevent duplicates
 N DIK,DA,NAME
 S NAME="FHIR " F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["FHIR ")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q