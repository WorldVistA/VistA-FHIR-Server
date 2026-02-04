C0FHIRTS ;VAMC/JS-FHIR SUITE TESTER ; 03-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 3, 2026;Build 4
 Q
EN ; Main entry point
 N DFN,DIC,Y,ENCPTR,RTN,I,SDT,EDT
 S (SDT,EDT)="" ; Initialize to prevent Undefined Variable error
 ;
 W !!,"--- C0FHIR Suite Tester ---",!
 ; 1. Select Patient
 S DIC="^DPT(",DIC(0)="AEMQ",DIC("A")="Select Patient: "
 D ^DIC Q:Y<0
 S DFN=+Y
 ;
 ; 2. Select Encounter (Optional)
 S DIC="^SCE(",DIC(0)="AEMQ",DIC("A")="Select Encounter (Optional): "
 S DIC("S")="I $P(^(0),U,2)=DFN" ; Only show encounters for this patient
 D ^DIC
 S ENCPTR=$S(Y>0:+Y,1:"")
 ;
 W !!,"Generating FHIR Bundle..."
 ; 3. Invoke Aggregator
 D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 ;
 ; 4. Display JSON Output (First 20 lines)
 W !!,"--- JSON Output Preview ---",!
 S I="" F  S I=$O(RTN(I)) Q:I=""!(I>20)  D
 . W RTN(I),!
 W !,"... [Output Truncated] ..."
 Q