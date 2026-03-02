C0FHIRUTL ;VAMC/JS-FHIR UTILITY TRANSFORMS ; 24-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 24, 2026;Build 2
 Q
 ;
SETPATH(TARGET,PATH,VAL) ; Build nested M-array from dot-notated path
 ; Input: TARGET - Array passed by reference (e.g., .MAP)
 ;        PATH   - The FHIR path string (e.g., "name.0.family")
 ;        VAL    - The value to set at that leaf
 ;
 N I,NODE,STR
 S STR="TARGET"
 ; Iterate through each segment of the path delimited by "."
 F I=1:1:$L(PATH,".") D
 . S NODE=$P(PATH,".",I)
 . ; If the node is numeric, it represents a JSON array index
 . I NODE=+NODE S STR=STR_"("_NODE_")"
 . ; Otherwise, it is a standard JSON object key
 . E  S STR=STR_"("""_NODE_""")"
 ;
 ; Execute the dynamic set command
 S @STR=VAL
 Q
 ;
FHIRDT(VADATE) ; Standardized Date Transformer
 ; Input: VADATE - FileMan internal date format
 ; Output: ISO-8601 formatted date/time
 Q:VADATE="" ""
 Q $$DATE^VPRSDA(VADATE)
 ;
LOINC(VITAL) ; Map Vital Type to LOINC
 ; Input: VITAL - IEN from File #120.51
 ; Output: LOINC Code
 N RES S RES=$$GET1^DIQ(120.51,VITAL,99.99) ; Assumes custom LOINC field mapping
 I RES="" S RES=$S(VITAL=1:"8480-6",VITAL=2:"8462-4",VITAL=3:"8867-4",1:"")
 Q RES
 ;
CVX(IMM) ; Map Immunization to CVX
 ; Input: IMM - IEN from File #9999999.14
 ; Output: CVX Code
 Q $$GET1^DIQ(9999999.14,IMM,.03)
 ;
RXNORM(DRUG) ; Map Drug to RxNorm
 ; Input: DRUG - IEN from File #50
 ; Output: RxNorm CUI
 N NDF,VAP S NDF=$$GET1^DIQ(50,DRUG,22,"I") ; Pointer to NDF
 S VAP=$$GET1^DIQ(50.68,NDF,19) ; RxNorm field in PSNDF
 Q VAP
 ;
UNIT(TYPE) ; Map VistA Vital units to UCUM
 ; Input: TYPE - Vital Type (e.g., "T", "P", "BP")
 Q:TYPE="T" "[degF]"
 Q:TYPE="W" "[lb_av]"
 Q:TYPE="H" "[in_us]"
 Q ""
 ;
REF(TYPE,IEN) ; Generate a FHIR Resource Reference string
 ; Input: TYPE - Resource Type (e.g., "Patient")
 ;        IEN  - VistA internal entry number
 Q:IEN="" ""
 Q TYPE_"/"_IEN
 ;
MERGEPART(TARGET,TAG,PIDX,SUBMAP) ; Merge child resource into parent at TAG.PIDX
 ; Input: TARGET - Parent MAP array (by ref)
 ;        TAG    - FHIR path segment (e.g., "participant")
 ;        PIDX   - 0-based array index
 ;        SUBMAP - Child bundle from CRAWL (has "entry",1,"resource")
 Q:'$D(SUBMAP("entry",1,"resource"))
 M TARGET(TAG,PIDX)=SUBMAP("entry",1,"resource")
 Q