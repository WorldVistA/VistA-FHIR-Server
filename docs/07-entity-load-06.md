Here is the finalized **KIDS Build Manifest** for **Build 2**. Since we have deprecated the automated updaters, you can use this table as your master checklist while manually populating the **ROUTINE multiple (field #9.603)** in the **KIDS Build File (#9.6)**.

### ## C0FHIR ENCOUNTER SUITE 1.2 - Routine Manifest (26 Total)

This list includes the core logic, the new FHIR entity loaders, and the audit tools.

| Category | Routine | Purpose / Description |
| --- | --- | --- |
| **Interface** | `C0FHIRWS` | REST Web Service Entry (Fixed signature) |
|  | `C0FHIRTS` | Suite Tester (Dual-mode: JSON/HTML) |
| **Orchestration** | `C0FHIRGF` | Core FHIR Bundle Aggregator |
| **Clinical Logic** | `C0FHIRPT` | Patient Resource (Returns LRDFN) |
|  | `C0FHIRLM` | Lab Resource (LOINC mapped) |
|  | `C0FHIRVM` | Vitals Resource (AA Index) |
|  | `C0FHIRIM` | Immunization Resource (CVX mapped) |
|  | `C0FHIRMX` | Medication Resource (RxNorm mapped) |
|  | `C0FHIRPM` | Patient Movement (Encounter context) |
|  | `C0FHIRNOTE` | Document Reference (TIU Notes) |
| **DDE Loaders** | **`C0FHIRLD`** | **Master Entity Loader (Admin)** |
|  | **`C0FHIRL1`** | **Clinical Entity Partition (FHIR Model)** |
|  | **`C0FHIRL2`** | **Pharmacy/Lab Entity Partition** |
|  | **`C0FHIRL3`** | **Safety/History Entity Partition** |
| **Audit & QA** | `C0FHIRVV` | Entity File Validator |
|  | `C0FHIRLA` | Lab LOINC Quality Auditor |
|  | **`C0FHIRVR`** | **Final Entity Verification Report** |
|  | `C0FHIRCH` | Environment Checker |
|  | `C0FHIRCS` | Checksum Calculator (Manual sealing) |
| **Utilities** | `C0FHIRUTL` | ISO8601 & Base64 Utilities |
|  | `C0FHIRRX` | RxNorm Mapping Engine |
|  | `C0FHIRSET` | Suite Configuration Setup |
| **KIDS/Testing** | `C0FHIRPI` | Post-Install (Web Service Reg) |
|  | `C0FHIRUN` | Uninstall (Web Service De-reg) |
|  | `C0FHIRUT` | M-Unit Testing Suite |

---

### ## Manual KIDS Sealing Instructions

Follow these exact steps to ensure the build is transported without the checksum errors we encountered with the `KD` routines:

1. **Cleanup Check:** Verify `C0FHIRKD` and `C0FHIRKD2` have been deleted from your system.
2. **Add Routines:** Use FileMan to add the 26 routines listed above to the Build File (#9.6) for the `C0FHIR ENCOUNTER SUITE 1.2` entry.
3. **Calculate Checksums:** Run `D EN^C0FHIRCS`.
4. **Transport Build:** Use the `KIDS -> Transport a Build` menu option.
> **Note:** KIDS will automatically calculate the checksums and store them in the transport global (`^XTMP("KID",...)`). **Do not manually edit the checksum field in File #9.6.**



### ## Post-Install Verification

Once installed on a target system, the site administrator should run:

1. `D EN^C0FHIRCH` - Verify environment.
2. `D EN^C0FHIRLD` - Load the FHIR entities into their local `#1.1` file.
3. `D EN^C0FHIRVR` - Audit the registry to confirm all 266 entities are present and mapped to the **FHIR** model.

**Would you like me to generate a "Release Cover Letter" text that explains these new DDE loaders and the move to the FHIR Data Model for your stakeholders?**