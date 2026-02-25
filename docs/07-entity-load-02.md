Understood. I have corrected the **Data Model** mapping to use **FHIR** (instead of SDA) and transitioned to a partitioned structure to handle the volume of data while staying under the routine size limit.

Below are the first two partitions: `C0FHIRLD` (Master/Admin) and `C0FHIRL1` (Clinical).

### 22. Entity Loader (Master & Admin): `C0FHIRLD`

*Fixed: Data Model set to FHIR.*

```mumps
C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"Loading Administrative Entities (FHIR Model)..."
 D ADMIN
 W !,"Loading Clinical Entities..."
 D EN^C0FHIRL1
 W !!,"Entity Load Complete. Run D EN^C0FHIRVV to validate.",!
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
 S NAME="VPR " F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["VPR ")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q

```

---

### 23. Entity Loader (Clinical Partition): `C0FHIRL1`

*Includes Vitals and Visits with the FHIR model.*

```mumps
C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER CLINICAL ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ;
 N FDA,IEN
 ; --- Entity #41: VPR VITAL MEASUREMENT ---
 S FDA(1.1,"+1,",.01)="VPR VITAL MEASUREMENT"
 S FDA(1.1,"+1,",.02)=120.5
 S FDA(1.1,"+1,",.04)="Observation"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="ObservationTime"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=7
 . S FDA(1.11,"+2,"_IEN(1)_",",1.1)="S VALUE=$P($G(VPRGMV),U) S:VALUE="""" DDEOUT=1"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #29: VPR VISIT ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="VPR VISIT"
 S FDA(1.1,"+1,",.02)=9000010
 S FDA(1.1,"+1,",.04)="Encounter"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="EncounterNumber"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=3
 . S FDA(1.11,"+2,"_IEN(1)_",",.03)="ID"
 . D UPDATE^DIE("","FDA")
 Q

```

---

### Implementation Guide

1. **Dependencies:** Ensure both routines are saved.
2. **Execution:** Run `D EN^C0FHIRLD`. It will:
* Wipe existing "VPR " entities (via `CLEAN`).
* Build the Patient and Facility headers.
* Call `C0FHIRL1` to build Vitals and Encounters.


3. **Validation:** Use `D EN^C0FHIRVV` (the validator we created earlier) to confirm the **Data Model** field is now set to "FHIR" for all processed entries.

**Would you like me to generate `C0FHIRL2` now to handle the Pharmacy and Laboratory entities from your report?**