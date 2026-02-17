C0FHIRTS ;VAMC/JS-FHIR SUITE TESTER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; Main Test Entry
 N DFN,RES,BNDL,ERR
 W !!,"--- C0FHIR Suite Build 2 Diagnostic Tester ---",!
 ;
 ; 1. Check for Static Global
 W !,"Checking Metadata Seal (^C0FHIR(1.5))..."
 I '$D(^C0FHIR(1.5)) D  Q
 . W " [FAIL]",!," >>> ERROR: Static global missing. Run D SEAL^C0FHIRSL."
 W " [OK]"
 ;
 ; 2. Select Test Patient
 S DFN=$$GETDFN I 'DFN Q
 ;
 ; 3. Run Aggregator
 W !!,"Executing C0FHIRGF Aggregator for DFN: ",DFN,"..."
 D GENFULL^C0FHIRGF(.RES,DFN)
 ;
 ; 4. Analyze Results
 I '$D(RES) W " [FAIL]",!," >>> ERROR: Aggregator returned no data." Q
 ;
 N I,LN S (LN,I)=0 F  S I=$O(RES(I)) Q:'I  S LN=LN+1
 W " [OK]",!," >>> Generated ",LN," nodes of JSON data."
 ;
 ; 5. Sample Output Check
 W !!,"Sample of FHIR Bundle (First 10 lines):",!
 F I=1:1:10 Q:'$D(RES(I))  W !,RES(I)
 W !, "...", !!
 Q
 ;
GETDFN() ; Simple DFN selector
 N DIC,X,Y S DIC=2,DIC(0)="AEMQ",DIC("A")="Select Test Patient: "
 D ^DIC
 Q +Y