Here is the finalized **Build 2 Routine Manifest**. This includes the **Troubleshooting Guide** and all previous modules. Your manual entry for the **KIDS Build File (#9.6)** should now reflect exactly **27 routines**.

---

### ## Final Routine Manifest: C0FHIR ENCOUNTER SUITE v1.2 (27 Total)

| Category | Routine | Description |
| --- | --- | --- |
| **Interface** | `C0FHIRWS` | REST Web Service Entry Point |
|  | `C0FHIRTS` | Suite Tester (JSON/HTML outputs) |
| **Orchestration** | `C0FHIRGF` | Core FHIR Bundle Aggregator |
| **Clinical Logic** | `C0FHIRPT` | Patient Resource (Demographics/Identifiers) |
|  | `C0FHIRLM` | Lab Resource (LOINC/File #63) |
|  | `C0FHIRVM` | Vitals Resource (AA Index/File #120.5) |
|  | `C0FHIRIM` | Immunization Resource (CVX Mapping) |
|  | `C0FHIRMX` | Medication Resource (RxNorm/Pharmacy) |
|  | `C0FHIRPM` | Patient Movement (Encounter Context) |
|  | `C0FHIRNOTE` | Document Reference (TIU Note Extraction) |
| **DDE Loaders** | `C0FHIRLD` | **Master Entity Loader (Admin & Header)** |
|  | `C0FHIRL1` | **Clinical Entity Partition (FHIR Model)** |
|  | `C0FHIRL2` | **Pharmacy & Lab Entity Partition** |
|  | `C0FHIRL3` | **Safety & History Entity Partition** |
| **Audit & QA** | `C0FHIRVV` | Entity File Validator (#1.1 Metadata) |
|  | `C0FHIRLA` | Lab LOINC Quality Auditor |
|  | `C0FHIRVR` | Final Entity Verification Report |
|  | **`C0FHIRTG`** | **Patient-Specific Troubleshooting Guide** |
|  | `C0FHIRCH` | Environment Configuration Checker |
|  | `C0FHIRCS` | Checksum Calculator (Manual RSUM) |
| **Utilities** | `C0FHIRUTL` | ISO8601, Base64, and Formatting Tools |
|  | `C0FHIRRX` | RxNorm Standard Mapping Engine |
|  | `C0FHIRSET` | Global Configuration & Settings Manager |
| **KIDS/Testing** | `C0FHIRPI` | Post-Install (Service Registration) |
|  | `C0FHIRUN` | Uninstall (Service De-registration) |
|  | `C0FHIRUT` | M-Unit Testing Core |
|  | `C0FHIRUN` | Uninstall Logic (Clean Deletion) |

---

### ## Administrative Implementation Map

To ensure the receiving site has a perfect deployment, I have visualized the data dependencies for the new troubleshooting and loading routines.

| Task | Routine | Site Admin Action |
| --- | --- | --- |
| **1. Registry Setup** | `C0FHIRLD` | Run at prompt to build FHIR entities. |
| **2. Semantic Check** | `C0FHIRLA` | Check for LOINC gaps in File #60. |
| **3. Clinical Debug** | `C0FHIRTG` | Trace specific patient data failures. |

---

### ## Manual Checksum Verification

Before transporting, I recommend generating your final **RSUM** list. This gives you a "snapshot" of the code integrity that you can include in your distribution notes.

**At the programmer prompt:**

```mumps
D EN^C0FHIRCS

```

**Would you like me to generate the M code for the "Environment Check" routine (`C0FHIRCH`) to ensure it explicitly checks for the existence of the DDE global (^DDE) and the web service file before the user attempts an install?**