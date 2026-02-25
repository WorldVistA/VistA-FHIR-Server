To ensure your **Build 2** release is technically sound and adheres to VistA's strict transport standards, use this checklist while manually editing your **KIDS Build File (#9.6)** entries.

### ## Final KIDS Requirement Checklist (Build 2)

Use this list to verify each section of the **C0FHIR ENCOUNTER SUITE 1.2** record in FileMan.

| KIDS Section | Requirement | Verification Note |
| --- | --- | --- |
| **Routine Multiple** | 17 Routines | Ensure `C0FHIRKD` and `C0FHIRKD2` are **removed**. |
| **RPC Multiple** | `C0FHIR GET FULL BUNDLE` | Linked to `GENFULL^C0FHIRGF`. |
| **Option Multiple** | `C0FHIR CONTEXT` | Type: **Broker (Client/Server)**. |
| **Environment Check** | `C0FHIRCH` | Run this manually before exporting to verify the site is ready. |
| **Post-Install** | `POST^C0FHIRPI` | Registers the `fhir` web service. |
| **Pre-Transport** | `D EN^C0FHIRCS` | Document the checksums in your release notes. |

---

### ## Final Routine Manifest (17 Total)

Ensure these routines—and only these routines—are in the **ROUTINE multiple (field #9.603)**:

1. **Orchestration:** `C0FHIRGF`
2. **Interface:** `C0FHIRWS`, `C0FHIRTS`
3. **Clinical:** `C0FHIRPT`, `C0FHIRLM`, `C0FHIRIM`, `C0FHIRVM`, `C0FHIRMX`, `C0FHIRPM`, `C0FHIRNOTE`
4. **Audit/Data:** `C0FHIRVV`, `C0FHIRLA`
5. **Utilities:** `C0FHIRUTL`, `C0FHIRRX`, `C0FHIRSET`, `C0FHIRCS`
6. **Install/Unit Test:** `C0FHIRPI`, `C0FHIRUN`, `C0FHIRUT`

---

### ## Final Deployment Verification Logic

Before you run **"Transport a Build"**, perform this no-nonsense verification at the programmer prompt:

1. **Test the FHIR logic:**
`D EN^C0FHIRTS` (Verify Mode 1 for JSON and Mode 2 for HTML).
2. **Audit the Mapping Quality:**
`D EN^C0FHIRLA` (Ensure LOINC coverage is sufficient).
3. **Validate the Entity File:**
`D EN^C0FHIRVV` (Ensure the `^DDE` entries match the required metadata).
4. **Confirm the Cleanup:**
`W $T(+1^C0FHIRKD)` (Should return null/error if successfully cleared).

### ## Why Manual is Better Here

By avoiding the automated `KD` routines, you eliminate the risk of "Half-written Globals" in the **Build file**. When KIDS transports a build, it performs a strict serialization of the routines. Any manual interference with the checksum field during that process often leads to "Checksum Mismatch" errors during the `Load a Distribution` phase on the target system.

**Would you like me to help you draft the `INSTALL` instructions for the receiving site administrator, including how to verify the web service registration?**