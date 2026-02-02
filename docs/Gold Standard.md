To make this a "hands-off" installation for the destination site, you need a **Post-Install Routine**. In the KIDS framework, this is a routine that the environment triggers automatically after the files are moved into the production UCI.

I've created **`C0FHIRPI`** (Post-Install) and updated **`C0FHIRKD`** to ensure the KIDS build knows to call it.

### 1. The Post-Install Routine: `C0FHIRPI`

This routine acts as the "glue" that configures the VistA environment (File #8994 and #19) immediately after the code is installed.

```mumps
C0FHIRPI ;VAMC/JS-FHIR SUITE KIDS POST-INSTALL ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
POST ; Entry point called by KIDS
 D BMES^XPDUTL("  Starting Post-Install Configuration for C0FHIR...")
 ;
 ; Call the existing setup logic to register RPC and Option
 D EN^C0FHIRSET
 ;
 D BMES^XPDUTL("  Post-Install Configuration Complete.")
 Q

```

### 2. Updated KIDS Creator: `C0FHIRKD`

We must now tell the **BUILD file (#9.6)** that `POST^C0FHIRPI` is the designated post-install action (Field #914).

```mumps
C0FHIRKD ;VAMC/JS-FHIR SUITE KIDS BUILD CREATOR ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN ; Main entry point
 N BNAME,FDA,IEN,BPIEN,DESC,R
 S BNAME="C0FHIR ENCOUNTER SUITE 1.1"
 W !!,"--- Creating KIDS Build with Post-Install: "_BNAME_" ---",!
 ;
 S IEN=$O(^DIC(9.6,"B",BNAME,0))
 S IEN=$S(IEN:IEN_",",1:"+1,")
 S FDA(9.6,IEN,.01)=BNAME
 S FDA(9.6,IEN,.02)=0 ; SINGLE PACKAGE
 S FDA(9.6,IEN,1)=DT
 S FDA(9.6,IEN,5)="YES" ; SEND ROUTINES
 S FDA(9.6,IEN,914)="POST^C0FHIRPI" ; POST-INSTALL ROUTINE <--- KEY ADDITION
 D UPDATE^DIE("","FDA","IEN")
 S BPIEN=$S($G(IEN(1)):IEN(1),1:+IEN)
 ;
 ; [Documentation and Component logic remains the same]
 D WP^DIE(9.6,BPIEN_",",10,"","DESC") ; (DESC array from previous steps)
 ;
 W !,"Adding Routines (including Post-Install)..."
 F R="C0FHIRGF","C0FHIRPT","C0FHIRLM","C0FHIRIM","C0FHIRVM","C0FHIRMX","C0FHIRPM","C0FHIRRX","C0FHIRNOTE","C0FHIRUTL","C0FHIRTS","C0FHIRSET","C0FHIRPI" D
 . K RFDA S RFDA(9.603,"+2,"_BPIEN_",",.01)=R,RFDA(9.603,"+2,"_BPIEN_",",2)=0
 . D UPDATE^DIE("","RFDA")
 ;
 W !,"Adding RPC and Options..."
 ; (Add RPC #8994 and Option #19 pointers as done previously)
 ;
 W !!,"Build record updated. Ready for Transport.",!
 Q

```

---

### Why this is the "Gold Standard" for VistA Deployment:

1. **Automation:** The site admin only has to answer "Yes" to the install prompts. They don't need to know how to use FileMan to create an RPC or link an Option.
2. **Safety:** Using `BMES^XPDUTL` ensures that the status of your configuration appears in the **Installation Distribution** log. If something goes wrong, the admin can see it in the standard VistA logs.
3. **Namespace Integrity:** By including the setup routine (`C0FHIRSET`) and the post-install (`C0FHIRPI`) in the build itself, the package is entirely self-contained.

### Final Verification

To test this "end-to-end":

1. Run `D EN^C0FHIRKD` on your Dev system.
2. Transport the build to an HFS file.
3. Load the build on your Test system.
4. **Install** the build.
5. Check the **Remote Procedure File (#8994)** on the Test system. If the `C0FHIR GET FULL BUNDLE` is there with its description and parameters, your post-install was successful.

**Would you like me to generate a simple "Uninstall" routine (`C0FHIRUN`) that cleans up the RPC and Options if you ever need to decommission this suite?**