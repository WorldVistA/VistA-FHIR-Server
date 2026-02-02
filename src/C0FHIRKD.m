C0FHIRKD ;VAMC/JS-FHIR SUITE KIDS BUILD CREATOR ; 01-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 1, 2026;Build 4
 Q
EN ; Main entry point
 N BNAME,FDA,IEN,BPIEN,DESC,R,RFDA
 S BNAME="C0FHIR ENCOUNTER SUITE 1.2"
 W !!,"--- Creating KIDS Build v1.2 (Complete): "_BNAME_" ---",!
 ;
 S IEN=$O(^DIC(9.6,"B",BNAME,0))
 S IEN=$S(IEN:IEN_",",1:"+1,")
 S FDA(9.6,IEN,.01)=BNAME
 S FDA(9.6,IEN,.02)=0 ; SINGLE PACKAGE
 S FDA(9.6,IEN,1)=DT
 S FDA(9.6,IEN,5)="YES" ; SEND ROUTINES
 S FDA(9.6,IEN,914)="POST^C0FHIRPI" ; POST-INSTALL ROUTINE
 D UPDATE^DIE("","FDA","IEN")
 S BPIEN=$S($G(IEN(1)):IEN(1),1:+IEN)
 ;
 ; Add Build Description
 K DESC
 S DESC(1)="C0FHIR Middleware Suite v1.2 (Enterprise Edition)"
 S DESC(2)="Includes Discovery Service, FHIR Aggregator, and M-Unit Tests."
 S DESC(3)="Run 'D EN^C0FHIRUT' after installation to verify."
 D WP^DIE(9.6,BPIEN_",",10,"","DESC")
 ;
 W !,"Adding Routines (16 Total)..."
 F R="C0FHIRGF","C0FHIRPT","C0FHIRLM","C0FHIRIM","C0FHIRVM","C0FHIRMX","C0FHIRPM","C0FHIRRX","C0FHIRNOTE","C0FHIRUTL","C0FHIRTS","C0FHIRSET","C0FHIRPI","C0FHIRUN","C0FHIRWS","C0FHIRUT" D
 . K RFDA S RFDA(9.603,"+2,"_BPIEN_",",.01)=R,RFDA(9.603,"+2,"_BPIEN_",",2)=0
 . D UPDATE^DIE("","RFDA")
 ;
 ; [Standard RPC #8994 and Option #19 mapping logic]
 W !,"Linking FileMan Components..."
 D RPC,OPT
 W !!,"Build record complete. Ready for 'Transport a Build'.",!
 Q
 ;
RPC N RPC S RPC=$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0))
 I RPC S FDA(9.618,"+3,"_BPIEN_",",.01)=RPC D UPDATE^DIE("","FDA")
 Q
OPT N OPT S OPT=$O(^DIC(19,"B","C0FHIR CONTEXT",0))
 I OPT S FDA(9.614,"+4,"_BPIEN_",",.01)=OPT D UPDATE^DIE("","FDA")
 Q