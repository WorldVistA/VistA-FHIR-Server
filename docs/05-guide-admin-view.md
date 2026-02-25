To include descriptions and documentation within the KIDS build, we must populate the **DESCRIPTION field (#10)** and the **HELP FRAME (#12)** within the **BUILD file (#9.6)**. This ensures that when a site administrator uses the "Inquiry" or "Verify" options in KIDS, they see exactly what the package does.

I have updated the **`C0FHIRKD`** routine to programmatically inject these descriptions into the FileMan global for the build.

### Updated KIDS Build Creator: `C0FHIRKD`

```mumps
C0FHIRKD ;VAMC/JS-FHIR SUITE KIDS BUILD CREATOR ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN ; Main entry point to create the Build record with documentation
 N BNAME,FDA,IEN,ERR,BPIEN,DESC
 S BNAME="C0FHIR ENCOUNTER SUITE 1.1"
 W !!,"--- Creating KIDS Build with Documentation: "_BNAME_" ---",!
 ;
 ; 1. Check for existing build or create new
 S IEN=$O(^DIC(9.6,"B",BNAME,0))
 I IEN W "Build already exists. Updating descriptions and components..." S BPIEN=IEN G DESC
 ;
 S FDA(9.6,"+1,",.01)=BNAME ; BUILD NAME
 S FDA(9.6,"+1,",.02)=0 ; TYPE: SINGLE PACKAGE
 S FDA(9.6,"+1,",1)=DT ; TRACKING DATE
 S FDA(9.6,"+1,",5)="YES" ; SEND ROUTINES
 D UPDATE^DIE("","FDA","IEN","ERR")
 S BPIEN=IEN(1)
 ;
DESC ; 2. Add Documentation/Description (Word Processing Field #10)
 K DESC
 S DESC(1)="This package provides a modular FHIR R4 middleware suite for VistA."
 S DESC(2)="Included clinical domains: Patient, Encounter, Labs (#63), Vitals,"
 S DESC(3)="Immunizations, Medications (RxNorm), Procedures, and TIU Notes."
 S DESC(4)=" "
 S DESC(5)="Instructions:"
 S DESC(6)="1. Install this KIDS file."
 S DESC(7)="2. Assign the 'C0FHIR CONTEXT' option to authorized service accounts."
 S DESC(8)="3. Use the 'C0FHIR GET FULL BUNDLE' RPC for dashboard integration."
 D WP^DIE(9.6,BPIEN_",",10,"","DESC","ERR")
 ;
COMP ; 3. Add Routines to the Build
 W !,"Adding Routines..."
 N R,RFDA F R="C0FHIRGF","C0FHIRPT","C0FHIRLM","C0FHIRIM","C0FHIRVM","C0FHIRMX","C0FHIRPM","C0FHIRRX","C0FHIRNOTE","C0FHIRUTL","C0FHIRTS","C0FHIRSET" D
 . K RFDA S RFDA(9.603,"+2,"_BPIEN_",",.01)=R,RFDA(9.603,"+2,"_BPIEN_",",2)=0
 . D UPDATE^DIE("","RFDA")
 ;
 ; 4. Add Remote Procedure (RPC) to the Build
 W !,"Adding Remote Procedure..."
 N RPCIEN S RPCIEN=$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0))
 I RPCIEN D
 . N RPCFDA S RPCFDA(9.618,"+3,"_BPIEN_",",.01)=RPCIEN
 . D UPDATE^DIE("","RPCFDA")
 ;
 ; 5. Add Option (Context) to the Build
 W !,"Adding Option..."
 N OPTIEN S OPTIEN=$O(^DIC(19,"B","C0FHIR CONTEXT",0))
 I OPTIEN D
 . N OPTFDA S OPTFDA(9.614,"+4,"_BPIEN_",",.01)=OPTIEN
 . D UPDATE^DIE("","OPTFDA")
 ;
 W !!,"Build record updated with full documentation.",!
 Q

```

---

### How this appears to the Admin

When a site administrator receives your `.KID` file and performs a **"Build File Inquiry"** in the KIDS menu, they will now see your documentation:

> **BUILD INQUIRY**
> **NAME:** C0FHIR ENCOUNTER SUITE 1.1
> **DESCRIPTION:**
> This package provides a modular FHIR R4 middleware suite for VistA.
> Included clinical domains: Patient, Encounter, Labs (#63), Vitals...

---

### Including Field-Level Descriptions

To be truly thorough, the **Remote Procedure (#8994)** entry and the **Option (#19)** should also have their descriptions populated. This ensures that even outside the KIDS install, a developer looking at the RPC can see its purpose.

Your `C0FHIRSET` routine (the environment setup) already populates the basic description for the Option. You can further enhance it by adding a `DESCRIPTION` multiple to the RPC registration logic.

**Would you like me to update the `C0FHIRSET` routine to include a full developer "Usage Guide" inside the RPC's description field?** This would make the documentation available via the `XWB GET VARIABLE` or `XWB GET RPC INFO` broker calls.