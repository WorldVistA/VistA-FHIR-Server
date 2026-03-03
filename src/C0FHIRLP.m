C0FHIRLP ;VAMC/JS-FHIR PARTICIPANT ENTITY CORRECTOR ; 23-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 23, 2026;Build 1
 Q
 ;
EN ; Correct C0FHIR ENCOUNTER PARTICIPANT entity for FHIR R4
 ; Uses FileMan FDA to update entity and items
 ; Source: File #9000010.06 (V-Provider). ID = VisitIEN,ProviderIEN (composite)
 ;
 N EIEN,FDA,IEN,ERR
 ;
 ; 1. Ensure entity exists (create if missing, like C0FHIRLE)
 S EIEN=$$ENTITY
 I 'EIEN W !,"[FAIL] Could not create/find C0FHIR ENCOUNTER PARTICIPANT entity." Q
 ;
 W !,"Correcting C0FHIR ENCOUNTER PARTICIPANT (IEN "_EIEN_")..."
 ;
 ; 2. Update entity: default file 9000010.06, display name Participant
 D ENTITYUPD(EIEN)
 ;
 ; 3. Clear existing SDA-style items
 D CLEANITEMS(EIEN)
 ;
 ; 4. Add FHIR participant items
 D LOADITEMS(EIEN)
 ;
 W !,"C0FHIR ENCOUNTER PARTICIPANT corrected."
 Q
 ;
ENTITY() ; Return IEN of C0FHIR ENCOUNTER PARTICIPANT, create if missing
 N FDA,IEN,ERR
 S IEN=$O(^DDE("B","C0FHIR ENCOUNTER PARTICIPANT",0))
 I IEN Q IEN
 ;
 ; Create entity via FileMan FDA (File 1.5)
 K FDA,ERR
 S FDA(1.5,"+1,",.01)="C0FHIR ENCOUNTER PARTICIPANT"
 S FDA(1.5,"+1,",.02)=9000010.06
 S FDA(1.5,"+1,",.04)="Participant"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) Q 0
 Q $G(IEN(1))
 ;
ENTITYUPD(EIEN) ; Update entity record via FileMan FDA
 ; Default file 9000010.06 (V-Provider), Display name Participant
 K FDA,ERR
 S FDA(1.5,EIEN_",",.02)=9000010.06
 S FDA(1.5,EIEN_",",.04)="Participant"
 S FDA(1.5,EIEN_",",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN","ERR")
 Q
 ;
CLEANITEMS(EIEN) ; Remove existing items via FileMan FDA
 N IIEN,FDA,ERR
 K FDA,ERR
 S IIEN=0
 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  I +IIEN=IIEN S FDA(1.51,EIEN_","_IIEN_",",.01)="@"
 I $D(FDA) D FILE^DIE("","FDA","ERR")
 Q
 ;
LOADITEMS(EIEN) ; Add FHIR participant items
 ; ID = composite "VisitIEN,ProviderIEN" from 9000010.06
 ; .01 = Provider (ptr 200), .04 = Role (P=Primary, S=Secondary)
 ;
 N FDA,IEN,ERR
 ;
 ; individual.reference - Practitioner/ProviderIEN
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="individual.reference"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="N PROV S PROV=$$GET1^DIQ(9000010.06,ID,.01,""I"") S VALUE=$S(PROV:""Practitioner/""_PROV,1:"""")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"  [WARN] individual.reference: ",$G(ERR("DIERR",1,"TEXT",1))
 ;
 ; type.0.coding.0.code - PPRF (primary) or SPRF (secondary) from .04
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="type.0.coding.0.code"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010.06
 S FDA(1.51,"+1,"_EIEN_",",.05)=.04
 S FDA(1.51,"+1,"_EIEN_",",4)="N R S R=VAL S VALUE=$S(R=""P"":""PPRF"",R=""S"":""SPRF"",1:""SPRF"")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"  [WARN] type.0.coding.0.code: ",$G(ERR("DIERR",1,"TEXT",1))
 ;
 ; type.0.coding.0.system - ParticipantType
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="type.0.coding.0.system"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="S VALUE=""http://terminology.hl7.org/CodeSystem/v3-ParticipationType"""
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 W !,"  Loaded 3 FHIR participant items."
 Q
