C0FHIRGF ;VAMC/JS-FHIR NATIVE DDE WRAPPER ; 21-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 21, 2026;Build 2
 Q
 ;
GENFULL(RESULT,DFN) ; Generate a full FHIR Patient Bundle using native DDE
 ; Input: DFN - Patient IEN (File #2)
 ; Output: RESULT - Global/Local array containing JSON
 ;
 N ENTITY,ERR,ID,DIQUIET
 S ENTITY="C0FHIR PATIENT"
 S ID=DFN
 S DIQUIET=1 ; Suppress FileMan noise
 ;
 ; 1. Initialize VistA environment for extraction
 D DT^DICRW ; Ensure DT and other FileMan vars are set
 ;
 ; 2. Call Native DDE Extraction Engine
 ; The native engine reads metadata directly from File #1.5
 ; and branches to FHIR logic if the DATA MODEL field = "FHIR"
 D EXTRACT^DDEOBJ(ENTITY,ID,.RESULT,.ERR)
 ;
 ; 3. Error Handling
 I $D(ERR) D  Q
 . S RESULT(1)="{""error"": ""DDE Extraction Failed"", ""message"": """_$G(ERR)_"""}"
 ;
 Q
 ;
TEST(DFN) ; Manual Test Entry Point
 N RES,I S DFN=$G(DFN) I 'DFN Q
 W !!,"Requesting Native DDE Extraction for DFN: ",DFN
 D GENFULL(.RES,DFN)
 ;
 I '$D(RES) W !,"No data returned from Native DDE." Q
 ;
 W !!,"--- Native DDE FHIR Output ---",!
 S I=0 F  S I=$O(RES(I)) Q:'I  W !,RES(I)
 W !,"------------------------------",!
 Q