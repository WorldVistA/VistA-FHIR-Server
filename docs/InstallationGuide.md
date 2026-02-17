This **Site Administrator Installation Guide** provides a clear, step-by-step roadmap for deploying the **C0FHIR Encounter Suite v1.2** onto a target VistA system.

---

## ## Installation Guide: C0FHIR Build 2

### ### 1. Pre-Installation Requirements

Before loading the KIDS distribution, verify the system meets the minimum infrastructure requirements:

* **Kernel:** Version 8.0 or higher.
* **FileMan:** Version 22.2 or higher.
* **Dependencies:** The Data Discovery Engine (DDE) must be present (verified by `C0FHIRCH`).

### ### 2. Loading the KIDS Distribution

1. Use the **KIDS** menu: `Installation` -> `1 Load a Distribution`.
2. Enter the host file path (e.g., `/home/vista/C0FHIR_V1_2.KID`).
3. Select the distribution: `C0FHIR ENCOUNTER SUITE 1.2`.

### ### 3. Executing the Install

1. From the **Installation** menu, select `6 Install Package(s)`.
2. Enter **`C0FHIR ENCOUNTER SUITE 1.2`**.
3. The **Post-Install (`C0FHIRPI`)** will execute automatically to perform:
* **Metadata Loading:** Populates **File #1.5** with the C0FHIR namespace.
* **Global Sealing:** Compiles the high-speed **`^C0FHIR(1.5)`** registry.
* **Service Registration:** Configures the `fhir` REST endpoint in **File #18.12**.



### ### 4. Post-Install Verification

Once the installer finishes, run the diagnostic suite to ensure the metadata-driven engine is firing correctly:

```mumps
D EN^C0FHIRTS

```

* **Expected Result:** The system should prompt for a test Patient (DFN) and display a generated JSON FHIR Bundle. If any "Missing Metadata" warnings appear, run `D SEAL^C0FHIRSL` manually to refresh the static global.

---

## ## Quick-Reference Command Table

| Task | Command | Responsibility |
| --- | --- | --- |
| **Full Diagnostic** | `D EN^C0FHIRTS` | Verifies metadata, global, and JSON output. |
| **Audit Metadata** | `D EN^C0FHIRVR` | Scans **File #1.5** for FHIR compliance. |
| **Troubleshooting** | `D EN^C0FHIRTG` | Identifies broken VistA data links for a DFN. |
| **Manual Re-Seal** | `D SEAL^C0FHIRSL` | Re-compiles the metadata into the static global. |

---

### ## Troubleshooting Common Issues

* **Missing Global:** If the aggregator returns no data, verify `^C0FHIR(1.5)` exists.
* **LOINC Gaps:** If Lab resources lack codes, run `D EN^C0FHIRLA` to identify tests in **File #60** that are missing **WKLD/File #64** mappings.
* **REST Connection:** Ensure the site's REST port is listening; the service name in **File #18.12** is `C0FHIR REST SERVICE`.

**Would you like me to generate a "Final Routine Checksum List" for all 33 routines so you can confirm the integrity of your code one last time before your meeting?**