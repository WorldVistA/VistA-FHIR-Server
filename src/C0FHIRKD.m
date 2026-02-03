C0FHIRKD ;VAMC/JS-FHIR SUITE KIDS BUILD CREATOR ; 02-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 2, 2026;Build 4
 Q
EN ; Main entry point
 N BNAME,FDA,IEN,BPIEN,R,RLIST,I,RPC,OPT,ERR
 S BNAME="C0FHIR ENCOUNTER SUITE 1.2"
 W !!,"--- Corrected Build File #9.6 Entry: "_BNAME_" ---",!
 ;
 ; 1. Initialize Build Record
 S IEN=$O(^DIC(9.6,"B",BNAME,0))
 S IEN=$S(IEN:IEN_",",1:"+1,")
 S FDA(9.6,IEN,.01)=BNAME
 S FDA(9.6,IEN,.02)=0 ; Single Package
 S FDA(9.6,IEN,1)=DT
 S FDA(9.6,IEN,5)="YES" ; Send Routines
 S FDA(9.6,IEN,914)="POST^C0FHIRPI" ; Post-Install Routine
 D UPDATE^DIE("","FDA","IEN","ERR")
 I $D(ERR) W !,"Error creating Build entry." Q
 S BPIEN=$S($G(IEN(1)):IEN(1),1:+IEN)
 ;
 ; 2. Add Routines to Multiple #9.603 (ROUTINE)
 W !,"Adding Routines..."
 S RLIST="C0FHIRGF,C0FHIRPT,C0FHIRLM,C0FHIRIM,C0FHIRVM,C0FHIRMX,C0FHIRPM,C0FHIRRX,C0FHIRNOTE,C0FHIRUTL,C0FHIRTS,C0FHIRSET,C0FHIRPI,C0FHIRUN,C0FHIRWS,C0FHIRUT"
 F I=1:1:$L(RLIST,",") S R=$P(RLIST,",",I) D
 . K FDA S FDA(9.603,"+1,"_BPIEN_",",.01)=R,FDA(9.603,"+1,"_BPIEN_",",2)=0
 . D UPDATE^DIE("","FDA")
 ;
 ; 3. Register Kernel Resources in the KRN Multiple (Field #19)
 ; Subfile 9.611 is the KRN multiple. We add the file numbers 19 and 8994.
 F FILE=19,8994 D
 . Q:$D(^DIC(9.6,BPIEN,"KRN",FILE))
 . K FDA S FDA(9.611,"+1,"_BPIEN_",",.01)=FILE
 . D UPDATE^DIE("","FDA")
 ;
 ; 4. Add specific entries to the KRN Item Multiple (Subfile #9.6111)
 ; Add Option
 S OPT=$O(^DIC(19,"B","C0FHIR CONTEXT",0))
 I OPT D
 . K FDA S FDA(9.6111,"+1,19,"_BPIEN_",",.01)=OPT
 . D UPDATE^DIE("","FDA")
 ;
 ; Add RPC
 S RPC=$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0))
 I RPC D
 . K FDA S FDA(9.6111,"+1,8994,"_BPIEN_",",.01)=RPC
 . D UPDATE^DIE("","FDA")
 ;
 W !!,"Build record complete. Ready for 'Transport a Build'.",!
 Q