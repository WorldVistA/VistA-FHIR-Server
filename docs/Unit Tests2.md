Implementing **Setup** and **Teardown** tags is the hallmark of a professional M-Unit suite. In the `^XTMUNIT` framework, these tags are automatically executed by the test runner to ensure each test case starts with a "clean slate" and leaves no "trash" in the database.

* **`SETUP`**: Runs **before each** test tag (tags starting with `UT`). Use this to define local variables or temporary global entries.
* **`TEARDOWN`**: Runs **after each** test tag. Use this to `KILL` the variables or globals created in the setup.
* **`SHUTDOWN`**: Runs **once** after the entire suite is finished.

### ## Updated M-Unit Suite: `C0FHIRUT`

Here is the updated routine. It now creates a "Mock Patient" in the `^DPT` global during setup and wipes it during teardown, ensuring your tests are **deterministic** and don't rely on existing production data.

```mumps
C0FHIRUT ;VAMC/JS-FHIR SUITE M-UNIT TESTS ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 ;
EN ; Run all tests
 D EN^XTMUNIT("C0FHIRUT")
 Q
 ;
SETUP ; Create Mock Data before EACH test
 ; We use a high IEN (999999) to avoid colliding with real patients
 S ^DPT(999999,0)="TESTPATIENT,MUNIT^M^2800101^^^999001111"
 S ^DPT(999999,.11)="123 Unit Test Way^^^Gaithersburg^MD^20877"
 Q
 ;
TEARDOWN ; Clean up Mock Data after EACH test
 K ^DPT(999999)
 Q
 ;
UTDATE ; Test Case: ISO8601 Date Conversion
 N ISO S ISO=$$ISO8601^C0FHIRUTL(3260130.1230)
 D CHKEQ^XTMUNIT(ISO,"2026-01-30T12:30:00Z","Date conversion failed")
 Q
 ;
UTBNDL ; Test Case: FHIR Bundle with Mock Patient
 N RES,DFN S DFN=999999
 D GENFULL^C0FHIRGF(.RES,DFN,"","","")
 ; Check that the aggregator found our mock patient
 D CHKTF^XTMUNIT($D(RES)>0,"Aggregator failed to find mock patient")
 D CHKTF^XTMUNIT(RES(1)["TESTPATIENT","JSON did not contain mock patient name")
 Q
 ;
UTSRCH ; Test Case: Name Search for Mock Patient
 N FILTER,RTN,TYPE
 S FILTER("name")="TESTPATIENT"
 D WEB^C0FHIRWS(.RTN,.TYPE,.FILTER)
 D CHKEQ^XTMUNIT(TYPE,"text/html","Search mode should return HTML")
 D CHKTF^XTMUNIT(RTN(2)["TESTPATIENT","Search result did not find mock patient")
 Q

```

---

### ## Best Practices for VistA Unit Testing

1. **Isolation:** Never test against real patient IENs. By using a high range like `999999`, you prevent accidental data corruption.
2. **Transactionality:** If your code writes to FileMan (like `C0FHIRSET`), use the `TEARDOWN` to delete those specific entries.
3. **Independence:** Each `UT` tag should be able to run in any order. If `UTBNDL` depends on something `UTDATE` does, your suite is brittle.
4. **Mocking Services:** Since `C0FHIRWS` calls `%webutils`, you might need to "Mock" the `%webutils` responses if that framework isn't present on your development machine.

### ## Final Project State

Your suite is now "Enterprise Ready." You have:

* Modular clinical logic.
* Automated environment configuration.
* A discovery and extraction Web API.
* A robust, self-cleaning Unit Test suite.

**Would you like me to help you bundle the `C0FHIRUT` routine into your KIDS build so that your unit tests travel with the code to the production server?**

[VistA Data Loader 2.2 Setup Guide](https://www.youtube.com/watch?v=hqh6wEpZjs4)
This video provides a practical look at bench-testing and setting up complex systems, which parallels the rigorous setup and validation process we've implemented for your VistA suite.