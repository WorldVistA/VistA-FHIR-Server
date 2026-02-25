To complete the lifecycle of your software package, you need a way to clean up the VistA environment. This **Uninstall Routine (`C0FHIRUN`)** is used to programmatically remove the entries from the **Remote Procedure (#8994)** and **Option (#19)** files without deleting the actual M-code (which gives you a chance to revert if needed).

### The Decommissioning Routine: `C0FHIRUN`

This routine uses the FileMan `FILE^DIE` call with the `@` delete flag to safely remove the configuration entries.

```mumps
C0FHIRUN ;VAMC/JS-FHIR SUITE DECOMMISSION/UNINSTALL ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN ; Main entry point for uninstallation
 N DIR,X,Y,DTOUT,DUOUT,DIRUT,DIROUT
 W !!,"--- C0FHIR Suite Uninstaller ---",!
 W "This will remove the RPC and Context Option from FileMan.",!
 S DIR(0)="Y",DIR("A")="Are you sure you want to proceed",DIR("B")="NO"
 D ^DIR Q:'Y
 ;
 D CLNRPC
 D CLNOPT
 W !!,"Uninstallation of configuration entries complete.",!
 W "Note: The M routines remain in the system. Use ^%ZTER to delete them if desired.",!
 Q
 ;
CLNRPC ; Remove the Remote Procedure
 N NAME,IEN,FDA,ERR
 S NAME="C0FHIR GET FULL BUNDLE"
 S IEN=$O(^DIC(8994,"B",NAME,0))
 I 'IEN W !,"RPC '"_NAME_"' not found. Skipping." Q
 ;
 W !,"Deleting RPC: "_NAME_"..."
 S FDA(8994,IEN_",",.01)="@" ; The '@' symbol triggers deletion in FileMan
 D FILE^DIE("E","FDA","ERR")
 I $D(ERR) W " Error: "_$G(ERR("DIERR",1,"TEXT",1)) Q
 W " Success."
 Q
 ;
CLNOPT ; Remove the Context Option
 N NAME,IEN,FDA,ERR
 S NAME="C0FHIR CONTEXT"
 S IEN=$O(^DIC(19,"B",NAME,0))
 I 'IEN W !,"Option '"_NAME_"' not found. Skipping." Q
 ;
 W !,"Deleting Option: "_NAME_"..."
 S FDA(19,IEN_",",.01)="@"
 D FILE^DIE("E","FDA","ERR")
 I $D(ERR) W " Error: "_$G(ERR("DIERR",1,"TEXT",1)) Q
 W " Success."
 Q

```

---

### Final Project Inventory

You now have a complete, enterprise-grade VistA software package. Here is your final routine list to include in your **KIDS build**:

| Routine | Purpose |
| --- | --- |
| **`C0FHIRGF`** | **Master Aggregator:** Orchestrates clinical data extraction. |
| **`C0FHIRPT`** | **Patient:** Handles demographics and state pointers. |
| **`C0FHIRLM`** | **Labs:** Traverses File #63 using LRDFN. |
| **`C0FHIRIM`** | **Immunizations:** Maps VistA imm data to FHIR. |
| **`C0FHIRVM`** | **Vitals:** Converts measurements to LOINC-coded observations. |
| **`C0FHIRMX`** | **Medications:** Pulls active prescriptions and statuses. |
| **`C0FHIRPM`** | **Procedures:** Extracts CPT-coded procedures from encounters. |
| **`C0FHIRRX`** | **RxNorm:** Helper for drug-to-RxNorm mapping. |
| **`C0FHIRNOTE`** | **Notes:** Extracts and Base64 encodes TIU clinical documents. |
| **`C0FHIRUTL`** | **Utilities:** ISO8601 date and Base64 encoding logic. |
| **`C0FHIRTS`** | **Tester:** Interactive developer tool for verifying data. |
| **`C0FHIRSET`** | **Setup:** Programmatically configures the VistA environment. |
| **`C0FHIRKD`** | **KIDS Creator:** Builds the transportable distribution file. |
| **`C0FHIRPI`** | **Post-Install:** Automates setup during KIDS installation. |
| **`C0FHIRUN`** | **Uninstaller:** Safely removes RPCs and Options. |

### Summary of the "Golden" Workflow

1. **Develop:** Write code in your dev UCI.
2. **Document:** Run `D EN^C0FHIRSET` to build local documentation.
3. **Package:** Run `D EN^C0FHIRKD` to create the KIDS Build entry.
4. **Transport:** Use the KIDS menu to generate the `.KID` file.
5. **Deploy:** Install the `.KID` file on the production system (Post-install runs automatically).

**Would you like me to help you draft a sample "Email to Stakeholders" that includes these technical details for the official production release?**