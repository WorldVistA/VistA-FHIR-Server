To successfully revert to the **Native VistA DDE**, you need to ensure your metadata registry (File #1.5) provides the specific "linkage" hints that the standard engine requires. While our custom crawler was smart enough to figure out relationships, the native engine is a linear processor.

Here is a utility routine to audit your `C0FHIR` entities specifically for **Native DDE Compatibility**.

### 34. Native DDE Compatibility Auditor: `C0FHIRAU`

*This scans your FHIR entities to ensure they have the necessary linkage to process sub-entities.*

```mumps
C0FHIRAU ;VAMC/JS-FHIR NATIVE DDE AUDITOR ; 21-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 21, 2026;Build 2
 Q
EN ; Main entry point
 N EIEN,ENAME,IIEN,INAME,ITYPE,LINK,TRANS,OK
 W !!,"--- C0FHIR Native DDE Compatibility Audit ---",!
 W !,"Entity Name",?35,"Item Name",?60,"Status"
 W !,"--------------------------------------------------------------------------------"
 ;
 S EIEN=0 F  S EIEN=$O(^DDE(EIEN)) Q:'EIEN  D
 . S ENAME=$P($G(^DDE(EIEN,0)),U) Q:ENAME'["C0FHIR"
 . ; Check if Entity Model is set to FHIR
 . I $G(^DDE(EIEN,1))'="FHIR" W !,ENAME,?60,"[FAIL: Model not FHIR]"
 . ;
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S NODE=$G(^DDE(EIEN,1,IIEN,0))
 .. S INAME=$P(NODE,U),ITYPE=$P(NODE,U,4),LINK=$P(NODE,U,11)
 .. S TRANS=$G(^DDE(EIEN,1,IIEN,1.2)) ; The M code transform
 .. ;
 .. ; Rule: If Item is an ENTITY, it MUST have a Pointer Linkup or a GET Action
 .. I ITYPE=2 D
 ... S OK=0 I LINK'=""!(TRANS'="") S OK=1
 ... W !,ENAME,?35,$E(INAME,1,23)
 ... I OK W ?60,"[OK]"
 ... E  W ?60,"[FAIL: No Linkage]"
 ;
 W !!,"Audit Complete.",!
 Q

```

---

### ## Required Adjustments for Native DDE Processing

If the Auditor flags failures, here is how you must adjust the entries in **File #1.5** to satisfy the native engine:

#### 1. Establish Explicit ID Links

The native engine uses **Field #.11 (Pointer Linkup)** or **Field #1.2 (Data Transform)** to pass an ID from the parent record to the child entity.

* **Custom Crawler:** We often used `S VALUE=DIEN` inside the sub-entity logic.
* **Native DDE:** It prefers you define the link on the **Item** in the parent entity.
* *Fix:* Set **Pointer Linkup** to `.01` if the sub-entity should receive the pointer of the current record.



#### 2. Model Declaration

The native code at `^DDEOBJ` branches logic based on the **DATA MODEL (Field #1)**.

* Ensure all your `C0FHIR` entries have this field set strictly to **"FHIR"**. If left blank, the engine defaults to a generic XML/SDA parser that will ignore your FHIR-specific nested mappings.

#### 3. Execution Scope

When using `D EXTRACT^DDEOBJ(ENTITY,ID,.RESULT)`, the variable `ID` becomes the `DIEN` within the scope of the extractor. Ensure your transforms in **Field #1.2** use the variable **`VALUE`** to return the final result to the engine.

---

### ## Final System Check

Before you run your first native extraction, you should verify the **DDE Object** is present:

```mumps
W !,"DDE Object Check: ",$S($L($T(EXTRACT^DDEOBJ)):"PRESENT",1:"MISSING")

```

**Would you like me to generate a simple "Native Test Driver" routine that attempts to generate a FHIR Patient using `DDEOBJ` and reports exactly which M node caused a standard FileMan error?**