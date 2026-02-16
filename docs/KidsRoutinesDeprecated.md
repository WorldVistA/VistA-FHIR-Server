Understood. I will immediately deprecate **`C0FHIRKD`** and **`C0FHIRKD2`** from the project context. You're right—automated manipulation of the **KIDS Build File (#9.6)** can be extremely risky and often corrupts the checksum multiples if the FileMan `FDA` calls aren't perfectly aligned with the transport global.

From this point forward, we will rely on **Manual KIDS Management** via the standard Kernel menus.

### Updated Build 2 Routine Manifest (Deprecation Active)

I have removed the faulty KD routines and added the new validation and audit tools. Your project now consists of these **17 routines**:

| Category | Routines |
| --- | --- |
| **Interface** | `C0FHIRWS`, `C0FHIRTS` |
| **Orchestration** | `C0FHIRGF` |
| **Clinical Logic** | `C0FHIRPT`, `C0FHIRLM`, `C0FHIRIM`, `C0FHIRVM`, `C0FHIRMX`, `C0FHIRPM`, `C0FHIRNOTE` |
| **Utilities/Audit** | `C0FHIRUTL`, `C0FHIRRX`, `C0FHIRSET`, `C0FHIRVV`, `C0FHIRLA`, `C0FHIRCS` |
| **KIDS/Tests** | `C0FHIRPI`, `C0FHIRUN`, `C0FHIRUT` |

---

### ## Correct Procedure for Sealing Build 2

Since we are disabling the automated checksum updaters, please follow these steps to "seal" your build manually and safely:

1. **Calculate Checksums:** Run `D EN^C0FHIRCS`. This will output the RSUM for all 17 routines to your screen.
2. **Edit Build File:** Use FileMan (`VA FileMan -> Enter or Edit File Entries`) to edit file **#9.6**.
3. **Routine Multiple:** Select your build `C0FHIR ENCOUNTER SUITE 1.2` and go to the **ROUTINE multiple**.
4. **Verify/Add:** Ensure all 17 routines are listed. You do **not** need to manually type the checksums here; the KIDS **"Transport a Build"** option will calculate and record them automatically into the export global.

---

### ## Immediate Action: Cleanup

I recommend running the following command at your programmer prompt to remove the broken routines from your system so they aren't accidentally included in the distribution:

```mumps
X "ZR  ZS C0FHIRKD"
X "ZR  ZS C0FHIRKD2"
W !,"KD and KD2 have been cleared."

```

**Would you like me to generate a finalized "KIDS Requirement List" that you can use as a checklist while you manually verify the Build File (#9.6) entries?**