C0FHIRTS ;VAMC/JS-FHIR SUITE TESTER ; 30-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 30, 2026;Build 1
 Q
EN ; Main entry point
 N DFN,ENCPTR,RES,DIR,X,Y,DTOUT,DUOUT,DIRUT,DIROUT
 W !!,"--- C0FHIR Suite Interactive Tester ---",!
 ;
 ; 1. Prompt for Patient
 S DIR(0)="PO^2:AEMQ",DIR("A")="Select Patient"
 D ^DIR K DIR I $D(DIRUT) Q
 S DFN=+Y
 ;
 ; 2. Prompt for Encounter (Optional)
 S DIR(0)="PO^409.68:AEMQ",DIR("A")="Select Encounter (Optional - Leave blank for ALL)"
 S DIR("S")="I $P(^(0),U,2)=DFN"
 D ^DIR K DIR
 I $G(DUOUT)!$G(DTOUT) Q
 S ENCPTR=+Y ; Will be 0 if blank
 ;
 W !!,"Processing..."
 ;
 ; 3. Call Aggregator
 ; If ENCPTR is 0, the aggregator will now handle the loop
 D GENFULL^C0FHIRGF(.RES,DFN,ENCPTR)
 ;
 I '$D(RES) W !,"FAIL: No results returned." Q
 W !,"SUCCESS: Bundle generated."
 D SHOW^C0FHIRTS(.RES,10) ; Preview first 10 lines
 Q