C0FHIRTS ;VAMC/JS-FHIR SUITE TESTER ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
EN N DFN,ENCPTR,RES,DIR,X,Y,SDT,EDT
 W !!,"--- C0FHIR Suite Tester ---",!
 S DIR(0)="PO^2:AEMQ",DIR("A")="Select Patient" D ^DIR Q:$D(DIRUT)  S DFN=+Y
 S DIR(0)="PO^409.68:AEMQ",DIR("A")="Select Encounter (Optional)",DIR("S")="I $P(^(0),U,2)=DFN"
 D ^DIR S ENCPTR=+Y
 I 'ENCPTR D
 . S DIR(0)="DO",DIR("A")="Start Date" D ^DIR S SDT=Y
 . S DIR(0)="DO",DIR("A")="End Date" D ^DIR S EDT=Y
 D GENFULL^C0FHIRGF(.RES,DFN,ENCPTR,SDT,EDT)
 I '$D(RES) W !,"No results." Q
 W !!,"JSON Preview:",! S I="" F  S I=$O(RES(I)) Q:I=""!(I>10)  W RES(I)
 Q