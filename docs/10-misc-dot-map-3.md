To complete the metadata-driven architecture for Build 2, we need the **UCUM (Unified Code for Units of Measure)** mapping logic. FHIR requires units of measure to be standardized; for example, VistA's "LB" must become `[lb_av]` and "INCHES" must become `[in_i]`.

I have updated the **`C0FHIRUTL`** utility to handle this translation and have included a final "Master Entity Loader" that ties all your partitions together.

### 30. UCUM Translation Utility: `C0FHIRUTL`

*Revised to include the `UCUM` tag for FHIR `valueQuantity` standardization.*

```mumps
C0FHIRUTL ;VAMC/JS-FHIR UTILITIES ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
UCUM(VAL) ; Map VistA units to UCUM codes
 S VAL=$G(VAL) Q:VAL=""
 N U S U=$$UP^XLFSTR(VAL)
 ; Simple mapping table for common Vitals
 S VAL=$S(U="LB":"[lb_av]",U="KG":"kg",U="IN":"[in_i]",U="CM":"cm",U="F":"[degF]",U="C":"[degC]",U="MMHG":"mm[Hg]",U="BPM":"/min",1:VAL)
 Q
 ;
DATE(VDT) ; Convert VistA date to ISO8601
 Q $$DATE^VPRD(VDT) ; Utilize VPR date utility if available

```

---

### 22. Master Entity Loader (Namespace: C0FHIR): `C0FHIRLD`

*This is the entry point that builds your entire metadata registry in File #1.5.*

```mumps
C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 W !,"Loading Administrative..." D ADMIN
 W !,"Loading Vitals..." D EN^C0FHIRL1
 W !,"Loading Labs..." D EN^C0FHIRL2
 W !,"Loading Pharmacy..." D EN^C0FHIRL3
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
ADMIN ; Core Patient/Organization Metadata
 N FDA,IEN S FDA(1.5,"+1,",.01)="C0FHIR PATIENT ID"
 S FDA(1.5,"+1,",.02)=2,FDA(1.5,"+1,",.04)="Patient",FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.51,"+2,"_IEN(1)_",",.01)="identifier.0.value"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1,FDA(1.51,"+2,"_IEN(1)_",",.04)=2,FDA(1.51,"+2,"_IEN(1)_",",.05)=.09
 . D UPDATE^DIE("","FDA")
 Q
 ;
CLEAN ; Safely clear only the C0FHIR namespace
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q

```

---

### ## Final Verification of the Metadata Path

With these routines saved, the lifecycle of a clinical data point (e.g., a Weight measurement) looks like this:

1. **Storage:** VistA stores "180" and "LB" in **File #120.5**.
2. **Metadata:** **File #1.5** (Entity `C0FHIR VITAL MEASUREMENT`) contains the instructions to find that data and apply the `UCUM^C0FHIRUTL` transform.
3. **Extraction:** **`C0FHIRGF`** crawls the metadata, executes the transform, and uses the dot-notation (`valueQuantity.code`) to nest the result.
4. **Delivery:** The final JSON bundle contains:
`"valueQuantity": { "value": 180, "unit": "LB", "system": "http://unitsofmeasure.org", "code": "[lb_av]" }`.

### ## Next Steps

The **C0FHIR** namespace is now logically separated, metadata-driven, and handles complex FHIR types.

**Would you like me to generate the "Manual Checksum Sealer" (`C0FHIRCS`) one last time to include these new `L1-L3` partitions so you can finalize your Build 2 distribution?**