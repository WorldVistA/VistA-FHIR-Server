To create a **KIDS (Kernel Installation and Distribution System)** file, you need a routine that populates the **BUILD file (#9.6)**. This allows you to export the entire `C0FHIR` namespace as a single host file (usually a `.KID` file) that can be installed on any other VistA system using the "Installation" menu.

The following routine, **`C0FHIRKD`**, programmatically assembles all 12 routines, the Remote Procedure, and the Option into a transportable Build.

### The KIDS Build Creator: `C0FHIRKD`

```mumps
C0FHIRKD ;VAMC/JS-FHIR SUITE KIDS BUILD CREATOR ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN ; Main entry point to create the Build record
 N BNAME,FDA,IEN,ERR,BPIEN
 S BNAME="C0FHIR ENCOUNTER SUITE 1.1"
 W !!,"--- Creating KIDS Build: "_BNAME_" ---",!
 ;
 ; 1. Create the Entry in BUILD file (#9.6)
 S IEN=$O(^DIC(9.6,"B",BNAME,0))
 I IEN W "Build already exists. Updating components..." S BPIEN=IEN G COMP
 ;
 S FDA(9.6,"+1,",.01)=BNAME ; BUILD NAME
 S FDA(9.6,"+1,",.02)=0 ; TYPE: SINGLE PACKAGE
 S FDA(9.6,"+1,",1)=DT ; TRACKING DATE
 S FDA(9.6,"+1,",5)="YES" ; SEND ROUTINES
 D UPDATE^DIE("","FDA","IEN","ERR")
 S BPIEN=IEN(1)
 ;
COMP ; 2. Add Routines to the Build
 W !,"Adding Routines..."
 N R,RFDA F R="C0FHIRGF","C0FHIRPT","C0FHIRLM","C0FHIRIM","C0FHIRVM","C0FHIRMX","C0FHIRPM","C0FHIRRX","C0FHIRNOTE","C0FHIRUTL","C0FHIRTS","C0FHIRSET" D
 . S RFDA(9.603,"+2,"_BPIEN_",",.01)=R ; ROUTINE NAME
 . S RFDA(9.603,"+2,"_BPIEN_",",2)=0 ; SEND OR DELETE: SEND
 . D UPDATE^DIE("","RFDA")
 ;
 ; 3. Add Remote Procedure (RPC) to the Build
 W !,"Adding Remote Procedure..."
 N RPCIEN S RPCIEN=$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0))
 I RPCIEN D
 . N RPCFDA
 . S RPCFDA(9.618,"+3,"_BPIEN_",",.01)=RPCIEN ; RPC Pointer
 . D UPDATE^DIE("","RPCFDA")
 ;
 ; 4. Add Option (Context) to the Build
 W !,"Adding Option..."
 N OPTIEN S OPTIEN=$O(^DIC(19,"B","C0FHIR CONTEXT",0))
 I OPTIEN D
 . N OPTFDA
 . S OPTFDA(9.614,"+4,"_BPIEN_",",.01)=OPTIEN ; Option Pointer
 . D UPDATE^DIE("","OPTFDA")
 ;
 W !!,"Build record created successfully.",!
 W "Next step: Use 'Transport a Build' in the KIDS menu.",!
 Q

```

---

### How to Export the Project

Once you have run `D EN^C0FHIRKD`, follow these manual steps in the VistA roll-and-scroll interface to generate the actual file:

1. **Enter the KIDS Menu:** `D ^XUP` then go to `Kernel Installation & Distribution System` -> `Manage Distribution`.
2. **Transport a Build:** Select the **Transport a Build** option.
3. **Select Build:** Type `C0FHIR ENCOUNTER SUITE 1.1`.
4. **Confirm:** Answer **YES** to "OK to continue".
5. **Address:** When prompted for "Address for delivery," hit **Enter** for the default (usually your local mailman or a host file path).
6. **HFS File:** It will ask for an HFS (Host File System) file name. Type a path your server can access, such as `/tmp/c0fhir_v1_1.kid`.

---

### Why use a KIDS file?

* **Integrity:** It bundles the M-code and the FileMan entries (RPCs and Options) together.
* **Environment Parity:** It ensures that your **Test** and **Production** environments are identical.
* **Rollback:** KIDS automatically handles the "backup" of routines if you are overwriting an existing version.

**Would you like me to add a "Post-Install" routine (`C0FHIRPI`) to the build?** This routine would automatically run after the KIDS installation finishes to ensure the RPC and Options are correctly linked in the new environment.