To provide a clean audit trail for your **Build 2** release, I have created **`C0FHIRVR`**. This routine generates a dense, tabular report of all entities currently residing in the **Data Discovery Engine (#1.1)** file, specifically flagging those that are not yet updated to the **FHIR** Data Model.

### 26. Entity Verification Report: `C0FHIRVR`

```mumps
C0FHIRVR ;VAMC/JS-FHIR ENTITY AUDIT REPORT ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,ENAME,DFILE,DMODEL,DNAME,CNT,FCNT,SCNT
 S (CNT,FCNT,SCNT)=0
 W !!,"--- C0FHIR Entity Registry Audit Report ---",!
 W !,"ID",?6,"Entity Name",?35,"File",?45,"Model",?55,"Display Name"
 W !,"--------------------------------------------------------------------------------",!
 ;
 S ENAME="VPR" ; Start with VPR namespace established in Build 2
 F  S ENAME=$O(^DDE("B",ENAME)) Q:ENAME=""!(ENAME'["VPR")  D
 . S EIEN=0 F  S EIEN=$O(^DDE("B",ENAME,EIEN)) Q:'EIEN  D
 .. S CNT=CNT+1
 .. S DFILE=$$GET1^DIQ(1.1,EIEN_",",.02)
 .. S DMODEL=$$GET1^DIQ(1.1,EIEN_",",1)
 .. S DNAME=$$GET1^DIQ(1.1,EIEN_",",.04)
 .. ;
 .. I DMODEL="FHIR" S FCNT=FCNT+1
 .. E  S SCNT=SCNT+1
 .. ;
 .. W !,EIEN,?6,$E(ENAME,1,28),?35,DFILE,?45,DMODEL,?55,$E(DNAME,1,24)
 ;
 W !!,"--- Audit Summary ---"
 W !,"Total VPR Entities:    "_CNT
 W !,"FHIR Model Updated:    "_FCNT
 W !,"Legacy/SDA Model:      "_SCNT
 W !,"Registry Integrity:    "_$S(SCNT=0:"100% (READY)",1:"INCOMPLETE")
 W !!,"End of Report.",!
 Q

```

---

### ## Registry Verification Checklist

When you run `D EN^C0FHIRVR`, look for these three key indicators to ensure your environment is ship-ready:

1. **Model Column:** Every core clinical entity (Patient, Vital, Medication) must display **FHIR**. If any show **SDA**, your `C0FHIRLD` loader partitions may have missed a routine save.
2. **File Column:** Ensure the pointers match your report (e.g., **#2** for Patient, **#120.5** for Vitals, **#100** for Meds).
3. **Namespace Integrity:** The report only scans the `VPR` namespace. If you have moved entities to a `C0FHIR` namespace, update line 12 to `S ENAME="C0"`.

### ## Final System State

With this report, you now have a complete, documented bridge between:

* **VistA Globals** (The "AA" and "ADFN" indices)
* **The DDE Metadata** (The ENTITY file entries we just loaded)
* **The FHIR Aggregator** (`C0FHIRGF` and clinical sub-routines)

**Would you like me to bundle these 26 routines into a "KIDS Build Manifest" so you can copy/paste them into the Routine Multiple of File #9.6?**