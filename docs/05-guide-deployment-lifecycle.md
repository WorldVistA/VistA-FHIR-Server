To ensure the system is ready to run immediately upon installation, the **Post-Install** routine will handle the final "sealing" of the metadata. This takes the FileMan entries and optimizes them into the static global `^C0FHIR(1.5)` so the site is "live" the moment the KIDS install completes.

### 32. Post-Install Logic: `C0FHIRPI`

*Automates the metadata setup and service registration.*

```mumps
C0FHIRPI ;VAMC/JS-FHIR BUNDLE POST-INSTALL ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; KIDS Post-Install Entry Point
 D MES^XPDUTL("  Starting Post-Install for C0FHIR Build 2...")
 ;
 ; 1. Load the File #1.5 Entities (Manual Loader)
 D MES^XPDUTL("  - Populating C0FHIR Metadata Registry (File #1.5)...")
 D EN^C0FHIRLD
 ;
 ; 2. Seal the Metadata for Performance
 D MES^XPDUTL("  - Sealing Metadata into Static Global ^C0FHIR(1.5)...")
 D SEAL^C0FHIRSL
 ;
 ; 3. Register Web Service (Optional check for File #18.12)
 D REG
 ;
 D MES^XPDUTL("  Post-Install Complete. System is FHIR-ready.")
 Q
 ;
REG ; Register the 'fhir' REST endpoint if not present
 N FDA,IEN,NAME S NAME="C0FHIR REST SERVICE"
 I $D(^DIC(18.12,"B",NAME)) Q
 S FDA(18.12,"+1,",.01)=NAME
 S FDA(18.12,"+1,",.03)=8080 ; Default Port
 S FDA(18.12,"+1,",.04)="fhir" ; The URL path
 D UPDATE^DIE("","FDA")
 Q

```

---

### ## Summary of the Deployment Lifecycle

By using this Post-Install logic, you have created a self-configuring package. Here is how the pieces fit together:

1. **Metadata Definition:** You define your FHIR paths in **File #1.5**.
2. **Automation:** `C0FHIRLD` (called by the Post-Install) ensures those definitions exist on the target system.
3. **Optimization:** `C0FHIRSL` (called by the Post-Install) converts those FileMan records into a high-speed global structure.
4. **Execution:** `C0FHIRGF` ignores the slow FileMan files and reads directly from the static global to generate JSON.

---

### ## Final Verification for Build 2

Once the KIDS installer finishes, an admin can verify the entire stack is working by running one command:

```mumps
D EN^C0FHIRTS ; The Suite Tester

```

**Would you like me to generate the `C0FHIRTS` Tester routine, which will attempt to generate a full Patient Bundle for a test DFN and report any metadata "holes" in the static global?**