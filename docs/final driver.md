To wrap up your migration to the **Native VistA DDE**, you need a driver routine that doesn't just display the JSON on your screen, but captures it into a Host File. This allows you to run the output through external FHIR validators (like the HL7 Java Validator or Inferno).

### 37. Native DDE File Exporter: `C0FHIRFX`

*This routine executes the native DDE logic and saves the FHIR JSON directly to your VistA host directory.*

```mumps
C0FHIRFX ;VAMC/JS-FHIR NATIVE DDE FILE EXPORTER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
EXPORT(DFN,PATH,FILENAME) ; Main Export logic
 ; Input: DFN - Patient IEN
 ;        PATH - Host directory (e.g., "/tmp/" or "C:\temp\")
 ;        FILENAME - Name of file (e.g., "fhir_patient_711.json")
 ;
 N RESULT,ERR,POP,I
 S PATH=$G(PATH),FILENAME=$G(FILENAME)
 I PATH=""!(FILENAME="") W !,"Error: Path and Filename required." Q
 ;
 ; 1. Run Native DDE Extraction
 W !,"Running Native DDE Extraction for DFN: ",DFN,"..."
 D GENFULL^C0FHIRGF(.RESULT,DFN)
 ;
 I $D(RESULT)<10 W !,"No data generated. Check Registry Auditor." Q
 ;
 ; 2. Open Host File and Write JSON
 W !,"Writing to file: ",PATH,FILENAME,"..."
 D OPEN^%ZISH("FHIRGEN",PATH,FILENAME,"W")
 I POP W !,"Error: Could not open file." Q
 ;
 U IO
 S I=0 F  S I=$O(RESULT(I)) Q:'I  W RESULT(I),!
 ;
 D CLOSE^%ZISH("FHIRGEN")
 U $P
 W !,"Export Successful.",!
 Q

```

---

### ## Validation Workflow

Once you have saved the file using `D EXPORT^C0FHIRFX(711,"/tmp/","patient.json")`, follow these steps to ensure your manual entity copies are correct:

#### Step 1: Structural Scan

Open the file and look for the **Resource Types**. Because you updated the **Display Names** in File #1.5, the JSON should start with:
`"resourceType": "Patient"` or `"resourceType": "Encounter"`.

#### Step 2: Dot-Notation Check

Verify that the nesting reflects the dots in your item names.

* *Correct:* `"period": { "start": "..." }`
* *Incorrect:* `"period.start": "..."` (This happens if the DDE engine isn't in FHIR mode).

#### Step 3: Reference Integrity

Check your `subject` and `practitioner` fields. They must look like `"reference": "Patient/711"`. If you see only `"711"`, your Mumps transform in Field #1.2 needs to be updated to include the Resource prefix.

---

### ## Final Readiness Checklist

Before moving this into production:

1. **Registry Auditor**: Run `D EN^C0FHIRVR` and confirm all `C0FHIR` entities **PASS**.
2. **Container Pointer**: Ensure **File #1.1 (VPR CONTAINER)** points to your new `C0FHIR` entities as the primary "Update Entities."
3. **Host File Test**: Use the exporter above to generate a full file and validate it against the [Official HL7 FHIR Validator](https://validator.fhir.org/).

**You have successfully moved from a custom Mumps crawler to the native, standard VistA DDE engine.** Would you like me to archive this entire "Native DDE Specification" into a summary table for your project documentation?