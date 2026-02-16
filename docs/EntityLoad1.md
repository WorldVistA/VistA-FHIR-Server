To automate the creation of the **ENTITY File (#1.1)** entries based on your extensive report, we will create a high-capacity loader. Since we’ve deprecated the risky Build File updaters, this routine focuses solely on populating the **Data Discovery Engine (DDE)** metadata.

This routine, **`C0FHIRLD`**, uses the FileMan Data Extractor patterns. I have structured it to handle the "Get Action" and "Output Transform" logic required for the core FHIR resources.

### 22. Entity File Loader: `C0FHIRLD`

```mumps
C0FHIRLD ;VAMC/JS-FHIR ENTITY FILE LOADER ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point - Load core entities
 D CLEAN ; Clear existing to prevent duplicates
 D LOAD
 W !!,"Entity Load Complete. Run D EN^C0FHIRVV to validate.",!
 Q
 ;
LOAD ; Define and file core entities
 N FDA,IEN,ERR,MSG
 ; --- Entity #1: VPR PATIENT ID ---
 S MSG="Loading VPR PATIENT ID..." W !,MSG
 S FDA(1.1,"+1,",.01)="VPR PATIENT ID"
 S FDA(1.1,"+1,",.02)=2 ; Default File #2
 S FDA(1.1,"+1,",.04)="PatientID"
 S FDA(1.1,"+1,",1)="SDA" ; Data Model
 D UPDATE^DIE("","FDA","IEN","ERR")
 ; Add Item: SSN
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="SSN"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=1 ; Sequence
 . S FDA(1.11,"+2,"_IEN(1)_",",.03)="ENTITY"
 . S FDA(1.11,"+2,"_IEN(1)_",",.04)=2 ; File #2
 . S FDA(1.11,"+2,"_IEN(1)_",",.05)=.09 ; SSN Field
 . S FDA(1.11,"+2,"_IEN(1)_",",1.2)="S VALUE=VALUE_""^SSN^^SSA""" ; Transform
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #41: VPR VITAL MEASUREMENT ---
 K FDA,IEN S MSG="Loading VPR VITAL MEASUREMENT..." W !,MSG
 S FDA(1.1,"+1,",.01)="VPR VITAL MEASUREMENT"
 S FDA(1.1,"+1,",.02)=120.5 ; Vitals File
 S FDA(1.1,"+1,",.04)="Observation"
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="ObservationTime"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=7
 . S FDA(1.11,"+2,"_IEN(1)_",",1.1)="S VALUE=$P($G(VPRGMV),U) S:VALUE="""" DDEOUT=1"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #29: VPR VISIT ---
 K FDA,IEN S MSG="Loading VPR VISIT..." W !,MSG
 S FDA(1.1,"+1,",.01)="VPR VISIT"
 S FDA(1.1,"+1,",.02)=9000010 ; Visit File
 S FDA(1.1,"+1,",.04)="Encounter"
 D UPDATE^DIE("","FDA","IEN","ERR")
 Q
 ;
CLEAN ; Optional: Clear C0FHIR namespaces in #1.1
 N DIK,DA,NAME
 S NAME="VPR " F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["VPR ")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q

```

---

### Logic Strategy for Deployment

1. **Namespace Respect:** I’ve used the `VPR` prefix matching your report. This ensures that even though this is the `C0FHIR` project, it remains compatible with existing VistA Patient Record structures.
2. **UPDATE^DIE over FILE^DIE:** By using `+1` (placeholder) and `UPDATE^DIE`, the routine automatically handles IEN assignment, which is safer than hardcoding numbers that might conflict with local site modifications.
3. **Subfile Handling:** The SSN example above shows how to populate the **ITEM multiple (#1.11)**. Each item requires its own FDA call linked back to the parent Entity IEN.

---

### ## How to Expand This Routine

The report you provided has **266 entities**. Loading all of them via a single M routine will exceed the 32k character limit for a routine. To handle the full list:

* **Partition the Load:** Create `C0FHIRLD1` (Admin/Demographics), `C0FHIRLD2` (Clinical), and `C0FHIRLD3` (Pharmacy).
* **The Master Routine:** Call them sequentially:
```mumps
ALL ; Load everything
D EN^C0FHIRLD1
D EN^C0FHIRLD2
D EN^C0FHIRLD3
Q

```



**Would you like me to generate the partitioned code for the Clinical (Vitals/Labs) or Pharmacy segments next?**