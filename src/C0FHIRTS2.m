C0FHIRTS ;VAMC/JS-FHIR SUITE TESTER ; 07-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 7, 2026;Build 2
 Q
EN ; Main entry point
 N DFN,DIC,Y,ENCPTR,RTN,I,SDT,EDT,DIR,MODE,FILTER
 S (SDT,EDT)=""
 ;
 W !!,"--- C0FHIR Suite Tester v1.3 ---",!
 S DIR(0)="S^1:JSON Extraction (by DFN);2:HTML Search Preview (by Name)"
 S DIR("A")="Select Test Mode",DIR("B")="1"
 D ^DIR Q:$D(DIRUT)  S MODE=Y
 ;
 I MODE=1 D  G EXIT
 . ; Mode 1: Standard FHIR Extraction
 . S DIC="^DPT(",DIC(0)="AEMQ",DIC("A")="Select Patient: "
 . D ^DIC Q:Y<0  S DFN=+Y
 . S DIC="^SCE(",DIC(0)="AEMQ",DIC("A")="Select Encounter (Optional): "
 . S DIC("S")="I $P(^(0),U,2)=DFN"
 . D ^DIC S ENCPTR=$S(Y>0:+Y,1:"")
 . W !!,"Generating FHIR Bundle..."
 . D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 . D DISP(.RTN)
 ;
 I MODE=2 D  G EXIT
 . ; Mode 2: HTML Discovery Search
 . R !,"Enter Patient Name for Search: ",NAME:DTIME Q:NAME=""
 . S FILTER("name")=NAME
 . W !!,"Generating HTML Discovery Page..."
 . D WEB^C0FHIRWS(.RTN,.FILTER)
 . D DISP(.RTN)
 ;
EXIT Q
 ;
DISP(ARY) ; Display first 20 lines of output
 W !!,"--- Output Preview ---",!
 N J S J="" F  S J=$O(ARY(J)) Q:J=""!(J>20)  D
 . W ARY(J),!
 W !,"... [Output Truncated] ...",!
 Q