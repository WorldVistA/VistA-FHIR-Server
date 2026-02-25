The code to add **Items (#1.51)** to the **Entities (#1.5)** is contained within the `UPDATE^DIE` calls inside each partition loader (`C0FHIRL1`, `C0FHIRL2`, etc.).

Because we are using a metadata-driven approach, we use **Subfile #1.51** to define the FHIR paths (like `valueQuantity.value`) and the logic (the "Data Transform" in field **#1.2**) required to fetch and format that data.

Below are the refined routines that build these item-level relationships for Vitals, Labs, and Pharmacy.

### 23. Vitals Item Loader: `C0FHIRL1`

This routine populates the `C0FHIR VITAL MEASUREMENT` entity with its component FHIR paths.

```mumps
C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER VITALS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; Called by Master Loader
 N FDA,IEN,ERR,EIEN
 S EIEN=$O(^DDE("B","C0FHIR VITAL MEASUREMENT",0)) Q:'EIEN
 ;
 ; Item 1: The Numerical Value (Direct FileMan Mapping)
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="valueQuantity.value"
 S FDA(1.51,"+1,"_EIEN_",",.02)=1 ; Sequence
 S FDA(1.51,"+1,"_EIEN_",",.04)=120.5 ; Source File
 S FDA(1.51,"+1,"_EIEN_",",.05)=1.2 ; Source Field (Rate/Reading)
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: The UCUM Unit Code (Transform Logic)
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="valueQuantity.code"
 S FDA(1.51,"+2,"_EIEN_",",.02)=2
 S FDA(1.51,"+2,"_EIEN_",",1.2)="S VALUE=$$GET1^DIQ(120.5,ID,1.2,""E""),VALUE=$P(VALUE,"" "",2) D UCUM^C0FHIRUTL(.VALUE)"
 D UPDATE^DIE("","FDA")
 ;
 ; Item 3: Effective Date (ISO8601 Transform)
 K FDA S FDA(1.51,"+3,"_EIEN_",",.01)="effectiveDateTime"
 S FDA(1.51,"+3,"_EIEN_",",.02)=3
 S FDA(1.51,"+3,"_EIEN_",",.04)=120.5,FDA(1.51,"+3,"_EIEN_",",.05)=.01
 S FDA(1.51,"+3,"_EIEN_",",1.2)="S VALUE=$$DATE^C0FHIRUTL(VALUE)"
 D UPDATE^DIE("","FDA")
 Q

```

---

### 24. Lab Item Loader: `C0FHIRL2`

This routine adds the logic for the **WKLD-to-LOINC** hop directly into the Item metadata.

```mumps
C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER LABS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,EIEN,LN
 S EIEN=$O(^DDE("B","C0FHIR LAB RESULT",0)) Q:'EIEN
 ; Logic snippet for WKLD -> LOINC
 S LN="N W,S S S=$O(^LAB(60,ID,1,0)),W=$$GET1^DIQ(60.01,S_"",""_ID_"","",2,""I""),VALUE=$$GET1^DIQ(64,W,25)"
 ;
 ; Item 1: The LOINC Code
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="code.coding.0.code"
 S FDA(1.51,"+1,"_EIEN_",",1.2)=LN
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: The Display Name
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="code.coding.0.display"
 S FDA(1.51,"+2,"_EIEN_",",.04)=60,FDA(1.51,"+2,"_EIEN_",",.05)=.01
 D UPDATE^DIE("","FDA")
 Q

```

---

### 25. Pharmacy Item Loader: `C0FHIRL3`

Handles the transition of medication orders into `MedicationRequest` paths.

```mumps
C0FHIRL3 ;VAMC/JS-FHIR ENTITY LOADER PHARMACY ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,EIEN
 S EIEN=$O(^DDE("B","C0FHIR MEDICATION",0)) Q:'EIEN
 ;
 ; Item 1: Medication Reference (RxNorm mapped)
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="medicationCodeableConcept.coding.0.code"
 S FDA(1.51,"+1,"_EIEN_",",1.2)="D RXNORM^C0FHIRRX(.VALUE,ID)"
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: Status Transform
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="status"
 S FDA(1.51,"+2,"_EIEN_",",.04)=100,FDA(1.51,"+2,"_EIEN_",",.05)=5
 S FDA(1.51,"+2,"_EIEN_",",1.2)="S VALUE=$S(VALUE=""dc"":""cancelled"",1:""active"")"
 D UPDATE^DIE("","FDA")
 Q

```

---

### Key Takeaways for your Build

1. **Direct IEN Linking:** We use `$O(^DDE("B",NAME,0))` to find the IEN of the parent Entity in **File #1.5** before adding items to **Subfile #1.51**.
2. **Dot-Notation Storage:** Note that the `.01` field of the Item multiple now stores the **FHIR Path**. Your `C0FHIRGF` crawler uses this string to build the JSON tree.
3. **Encapsulated Transforms:** The complex M code for things like `UCUM` or `RXNORM` is stored right in the metadata, making the aggregator code completely generic.

**Would you like me to generate a "Registry Sealer" routine that loops through File #1.5 and converts all these definitions into a static global `^C0FHIR(1.5)` for faster transport in your KIDS build?**