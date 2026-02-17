C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY & LAB ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Called by Master Loader
 N FDA,IEN,ERR
 ; --- Entity: C0FHIR LAB RESULT ---
 S FDA(1.5,"+1,",.01)="C0FHIR LAB RESULT"
 S FDA(1.5,"+1,",.02)=63.04 ; CH sub-file
 S FDA(1.5,"+1,",.04)="Observation"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="Code"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1
 . ; Logic: Resolve File 60 -> Specimen -> File 64 -> LOINC
 . S FDA(1.51,"+2,"_IEN(1)_",",1.2)="N W,L S W=$$GET1^DIQ(60,ID,1,""I""),L=$$GET1^DIQ(64,W,25) S VALUE=L_""^""_VALUE_""^LN"""
 . D UPDATE^DIE("","FDA")
 Q