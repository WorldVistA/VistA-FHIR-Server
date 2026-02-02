C0FHIRSET ;VAMC/JS-FHIR SUITE ENVIRONMENT SETUP ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN ; Main entry point
 W !!,"--- C0FHIR Environment Setup (v1.1) ---",!
 D RPC,OPT
 W !!,"Setup complete. RPC and Context Option are now self-documenting.",!
 Q
 ;
RPC ; Register/Update RPC in File #8994
 N FDA,IEN,ERR,NAME,RPCP,DESC
 S NAME="C0FHIR GET FULL BUNDLE"
 W !,"Registering/Updating RPC: "_NAME_"..."
 S IEN=$O(^DIC(8994,"B",NAME,0))
 S IEN=$S(IEN:IEN_",",1:"+1,")
 S FDA(8994,IEN,.01)=NAME
 S FDA(8994,IEN,.02)="GENFULL",FDA(8994,IEN,.03)="C0FHIRGF"
 S FDA(8994,IEN,.04)=2,FDA(8994,IEN,.07)=1
 D UPDATE^DIE("","FDA","IEN","ERR")
 S RPCP=$S($G(IEN(1)):IEN(1),1:+IEN)
 ;
 ; Add Usage Guide to RPC Description Field (#10)
 K DESC
 S DESC(1)="USAGE GUIDE for C0FHIR ENCOUNTER DASHBOARD"
 S DESC(2)="----------------------------------------"
 S DESC(3)="INPUTS:"
 S DESC(4)="  1. DFN (Req): Internal Patient IEN from File #2."
 S DESC(5)="  2. ENCPTR (Opt): Internal Encounter IEN from File #409.68."
 S DESC(6)="  3. SDT (Opt): Start Date (FileMan format). Defaults to 0."
 S DESC(7)="  4. EDT (Opt): End Date (FileMan format). Defaults to T."
 S DESC(8)=" "
 S DESC(9)="OUTPUT:"
 S DESC(10)="  Returns a FHIR R4 Bundle (Collection) as a Global Array."
 S DESC(11)="  Includes: Patient, Encounter, Labs, Vitals, Meds, and Notes."
 D WP^DIE(8994,RPCP_",",10,"","DESC")
 ;
 ; Re-sync Parameters
 K ^DIC(8994,RPCP,2)
 D PARAM(RPCP,1,"DFN",1),PARAM(RPCP,2,"ENCPTR",0)
 D PARAM(RPCP,3,"SDT",0),PARAM(RPCP,4,"EDT",0)
 W " Success."
 Q
 ;
PARAM(RPC,SEQ,PNAME,REQ) ; Add Parameters
 N PFDA S PFDA(8994.02,"+2,"_RPC_",",.01)=PNAME,PFDA(8994.02,"+2,"_RPC_",",.02)=SEQ
 S PFDA(8994.02,"+2,"_RPC_",",.03)=1,PFDA(8994.02,"+2,"_RPC_",",.04)=REQ
 D UPDATE^DIE("","PFDA")
 Q
 ;
OPT ; Create/Update Context Option (#19)
 N FDA,NAME,OPTIEN,DESC
 S NAME="C0FHIR CONTEXT"
 W !,"Updating Context Option: "_NAME_"..."
 S OPTIEN=$O(^DIC(19,"B",NAME,0))
 S IEN=$S(OPTIEN:OPTIEN_",",1:"+1,")
 S FDA(19,IEN,.01)=NAME,FDA(19,IEN,.04)="B"
 S FDA(19,IEN,1)="Enables FHIR Dashboard data extraction."
 D UPDATE^DIE("","FDA","IEN")
 S OPTIEN=$S($G(IEN(1)):IEN(1),1:+OPTIEN)
 ; Attach RPC to Option
 I '$D(^DIC(19,OPTIEN,10,"B",$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0)))) D
 . K FDA S FDA(19.05,"+2,"_OPTIEN_",",.01)="C0FHIR GET FULL BUNDLE"
 . D UPDATE^DIE("","FDA")
 W " Success."
 Q