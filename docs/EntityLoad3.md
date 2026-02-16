Continuing the partition strategy, **`C0FHIRL2`** handles the Pharmacy and Laboratory entities. These are particularly complex because they involve nested pointers (e.g., Prescription pointing to Drug) and the `LRDFN` logic we reconciled earlier.

### 24. Entity Loader (Pharmacy & Lab Partition): `C0FHIRL2`

*Model: FHIR*

```mumps
C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY & LAB ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Entry point called by Master Loader
 N FDA,IEN,ERR
 ;
 ; --- Entity #56: VPR MEDICATION ---
 S FDA(1.1,"+1,",.01)="VPR MEDICATION"
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
 ; --- Entity #13: VPR LAB ORDER ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="VPR LAB ORDER"
 S FDA(1.1,"+1,",.02)=100
 S FDA(1.1,"+1,",.04)="LabOrder"
 S FDA(1.1,"+1,",1)="FHIR"
 ; Complex "Get Entry Action" logic from your report
 S FDA(1.1,IEN(1)_",",1.1)="S:'DFN&ID DFN=+$P($G(^OR(100,ID,0)),U,2) S LRDFN=+$G(^DPT(DFN,""LR""))"
 D UPDATE^DIE("","FDA","IEN")
 ;
 ; --- Entity #17: VPR LRCH RESULT ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="VPR LRCH RESULT"
 S FDA(1.1,"+1,",.02)=63.04 ; Chemistry sub-file
 S FDA(1.1,"+1,",.04)="Result"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 Q

```

---

### Master Routine Update

You should update the `EN` tag in **`C0FHIRLD`** to include this new clinical partition:

```mumps
EN ; Master Entry point update
 D CLEAN
 W !!,"Loading Administrative Entities..." D ADMIN
 W !,"Loading Clinical Partition 1..." D EN^C0FHIRL1
 W !,"Loading Pharmacy/Lab Partition 2..." D EN^C0FHIRL2
 W !!,"Entity Load Complete."
 Q

```

---

### ## Critical Mapping Note for Labs

As specified in **Entity #17 (VPR LRCH RESULT)**, the system expects the ID to be the IENS string `'IDT,LRDFN'`. When your loader creates these records, it establishes the metadata that the `C0FHIRLM` routine uses to traverse the `"CH"` node in File #63.

### Next Step

With the core Admin, Clinical, and Pharmacy/Lab entities mapped to the **FHIR Data Model**, your database is prepared for high-fidelity extraction.

**Would you like me to generate `C0FHIRL3` to handle the specialized history and safety entities, such as Allergies (#31) and the Problem List (#11)?**