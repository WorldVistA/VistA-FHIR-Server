C0FHIRUN ;VAMC/JS-FHIR SUITE DECOMMISSION/UNINSTALL ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 Q
EN ; Main entry point for uninstallation
 N DIR,X,Y,DTOUT,DUOUT,DIRUT,DIROUT
 W !!,"--- C0FHIR Suite Uninstaller ---",!
 W "This will remove the RPC, Context Option, and Web Service registration.",!
 S DIR(0)="Y",DIR("A")="Are you sure you want to proceed",DIR("B")="NO"
 D ^DIR Q:'Y
 ;
 ; 1. Remove Web Service
 W !,"Deregistering 'fhir' web service..."
 D deleteService^%webutils("GET","fhir")
 ;
 ; 2. Clean FileMan entries
 D CLNRPC
 D CLNOPT
 ;
 W !!,"Decommissioning complete.",!
 Q
 ;
CLNRPC ; Remove the Remote Procedure
 N NAME,IEN,FDA,ERR
 S NAME="C0FHIR GET FULL BUNDLE"
 S IEN=$O(^DIC(8994,"B",NAME,0))
 I IEN D
 . W !,"Deleting RPC: "_NAME_"..."
 . S FDA(8994,IEN_",",.01)="@"
 . D FILE^DIE("E","FDA","ERR")
 Q
 ;
CLNOPT ; Remove the Context Option
 N NAME,IEN,FDA,ERR
 S NAME="C0FHIR CONTEXT"
 S IEN=$O(^DIC(19,"B",NAME,0))
 I IEN D
 . W !,"Deleting Option: "_NAME_"..."
 . S FDA(19,IEN_",",.01)="@"
 . D FILE^DIE("E","FDA","ERR")
 Q