C0FHIRLE ;VAMC/JS-FHIR ENTITY LOADER ENCOUNTER ; 23-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 23, 2026;Build 2
 Q
 ;
EN ; Main entry - Create/update C0FHIR ENCOUNTER entity with FHIR R4 items
 ; Uses FileMan UPDATE^DIE to populate File #1.5 (DDE Entity) and #1.51 (Items)
 ;
 N EIEN,FDA,IEN,ERR,MSG
 ;
 ; 1. Ensure C0FHIR ENCOUNTER entity exists
 S EIEN=$$ENTITY
 I 'EIEN W !,"[FAIL] Could not create/find C0FHIR ENCOUNTER entity." Q
 ;
 ; 2. Add or update FHIR items (clear existing items first for idempotent reload)
 D CLEANITEMS(EIEN)
 ;
 ; 3. Load FHIR R4 item mappings per 01-spec-encounter.md
 W !,"Loading C0FHIR ENCOUNTER items..."
 D LOADITEMS(EIEN)
 ;
 W !,"C0FHIR ENCOUNTER entity updated. Run D SEAL^C0FHIRSL to reseal metadata."
 Q
 ;
ENTITY() ; Return IEN of C0FHIR ENCOUNTER, create if missing
 N IEN,FDA,ERR,N,F,R
 S IEN=$O(^DDE("B","C0FHIR ENCOUNTER",0))
 I IEN Q IEN
 ;
 ; Create entity shell: Name^DefaultFile^Display^ResourceType
 S N="C0FHIR ENCOUNTER",F=9000010,R="Encounter"
 S IEN=$O(^DDE(" "),-1)+1
 S ^DDE(IEN,0)=N_U_F_U_U_R
 S ^DDE(IEN,1)="FHIR"
 S ^DDE("B",N,IEN)=""
 Q IEN
 ;
CLEANITEMS(EIEN) ; Remove existing items from entity (for clean reload)
 N IIEN
 S IIEN=0
 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  K ^DDE(EIEN,1,IIEN)
 K ^DDE(EIEN,1,0)
 Q
 ;
LOADITEMS(EIEN) ; Add FHIR R4 items via FileMan FDA
 ; Source: File #9000010 (Visit), ID = Visit IEN
 ; Field 4 = OUTPUT TRANSFORM (per DDE DD 1.51,4). Field 6 = GET ACTION.
 ; Transform-only items use GET ACTION (6); file-sourced items use OUTPUT TRANSFORM (4).
 ;
 N FDA,IEN,ERR
 ;
 ; identifier.0.value - Visit IEN (ID in CRAWL). No FILE/FIELD; use GET ACTION.
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="identifier.0.value"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="S VALUE=ID"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"  [WARN] identifier.0.value: ",$G(ERR("DIERR",1,"TEXT",1))
 ;
 ; identifier.0.system - transform-only
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="identifier.0.system"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="S VALUE=""urn:oid:2.16.840.1.113883.4.349"""
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; status - transform-only
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="status"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="S VALUE=""finished"""
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; class.code - ActCode from Visit Type (.07); OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="class.code"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.07
 S FDA(1.51,"+1,"_EIEN_",",4)="N VTYPE S VTYPE=VAL S VALUE=$S(VTYPE=""A"":""AMB"",VTYPE=""I"":""IMP"",VTYPE=""E"":""EMER"",1:""NONAC"")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; class.system - transform-only
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="class.system"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",6)="S VALUE=""http://terminology.hl7.org/CodeSystem/v3-ActCode"""
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; type.0.text - Visit type display; OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="type.0.text"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.07
 S FDA(1.51,"+1,"_EIEN_",",4)="S VALUE=$$GET1^DIQ(9000010,ID_"","",.07,""E"")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; subject.reference; OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="subject.reference"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.05
 S FDA(1.51,"+1,"_EIEN_",",4)="S VALUE=""Patient/""_VAL"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; period.start; OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="period.start"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.01
 S FDA(1.51,"+1,"_EIEN_",",4)="S VALUE=$$DATE^VPRSDA(VAL)"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; period.end; OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="period.end"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.18
 S FDA(1.51,"+1,"_EIEN_",",4)="N EDT S EDT=VAL S VALUE=$S(EDT:$$DATE^VPRSDA(EDT),1:"""")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 ; location.0.location.reference; OUTPUT TRANSFORM
 K FDA,IEN,ERR
 S FDA(1.51,"+1,"_EIEN_",",.01)="location.0.location.reference"
 S FDA(1.51,"+1,"_EIEN_",",.03)="S"
 S FDA(1.51,"+1,"_EIEN_",",.04)=9000010
 S FDA(1.51,"+1,"_EIEN_",",.05)=.22
 S FDA(1.51,"+1,"_EIEN_",",4)="S VALUE=$S(VAL:""Location/""_VAL,1:"""")"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 W !,"  Loaded 10 FHIR Encounter items."
 Q
