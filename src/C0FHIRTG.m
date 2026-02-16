C0FHIRTG ;VAMC/JS-FHIR TROUBLESHOOTING GUIDE ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N DFN,MSG
 W !!,"--- C0FHIR Build 2 Diagnostic Tool ---",!
 R "Enter Patient DFN to test: ",DFN:DTIME E  Q
 I '$D(^DPT(+DFN,0)) W !,"[ERR] Invalid DFN." Q
 ;
 D CHKLAB(DFN)
 D CHKVIT(DFN)
 D CHKMED(DFN)
 W !!,"Diagnostics complete.",!
 Q
 ;
CHKLAB(DFN) ; Check Lab Data integrity
 N LRDFN S LRDFN=$G(^DPT(DFN,"LR"))
 W !,"Checking Lab... "
 I 'LRDFN W "[FAIL] No LRDFN in File #2. Lab data will NOT export." Q
 I '$D(^LR(LRDFN)) W "[FAIL] LRDFN exists but ^LR global node is missing." Q
 W "[OK] Lab gateway established."
 Q
 ;
CHKVIT(DFN) ; Check Vitals "AA" Index
 W !,"Checking Vitals... "
 I '$O(^GMR(120.5,"AA",DFN,0)) D
 . W "[WARN] No Vitals found in 'AA' index for this patient."
 . I $D(^GMR(120.5,"C",DFN)) W !,"  -> DATA EXISTS in 'C' index. System needs RE-INDEXING."
 E  W "[OK] Vitals index active."
 Q
 ;
CHKMED(DFN) ; Check Medication Pointers
 N ORPK,IFN,CNT S (CNT,IFN)=0
 W !,"Checking Meds... "
 F  S IFN=$O(^OR(100,"AC",DFN,IFN)) Q:'IFN  D
 . S ORPK=$P($G(^OR(100,IFN,4)),U)
 . I ORPK'="",ORPK["R",'$D(^PSRX(+ORPK)) S CNT=CNT+1
 I CNT>0 W "[FAIL] found "_CNT_" broken links from Order (#100) to Rx (#52)."
 E  W "[OK] Medication links verified."
 Q