C0FHIRFX ;VAMC/JS-FHIR NATIVE DDE FILE EXPORTER ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
EXPORT(DFN,PATH,FILENAME) ; Main Export logic
 ; Input: DFN - Patient IEN
 ;        PATH - Host directory (e.g., "/tmp/" or "C:\temp\")
 ;        FILENAME - Name of file (e.g., "fhir_patient_711.json")
 ;
 N RESULT,ERR,POP,I
 S PATH=$G(PATH),FILENAME=$G(FILENAME)
 I PATH=""!(FILENAME="") W !,"Error: Path and Filename required." Q
 ;
 ; 1. Run Native DDE Extraction
 W !,"Running Native DDE Extraction for DFN: ",DFN,"..."
 D GENFULL^C0FHIRGF(.RESULT,DFN)
 ;
 I $D(RESULT)<10 W !,"No data generated. Check Registry Auditor." Q
 ;
 ; 2. Open Host File and Write JSON
 W !,"Writing to file: ",PATH,FILENAME,"..."
 D OPEN^%ZISH("FHIRGEN",PATH,FILENAME,"W")
 I POP W !,"Error: Could not open file." Q
 ;
 U IO
 S I=0 F  S I=$O(RESULT(I)) Q:'I  W RESULT(I),!
 ;
 D CLOSE^%ZISH("FHIRGEN")
 U $P
 W !,"Export Successful.",!
 Q