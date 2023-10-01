# Changes Description
Introduced new class 'CaseSelector.cls' responsible selecting Cases with additional fields. Modified 'preventStatusChangeByNotAnOwner' method of 'CaseService.cls' to allow modifying Case status without claiming Case if Owner of Case is Inactive User. Modified tests to cover new logic. Created tests and 'TestDataFactory.cls' to test 'CaseSelector.cls'. Added new constant to 'Constants.cls'.
# Pre-Deployment Manual Steps
None.
# Metadata Changes Listing
- Apex Classes:
    - CaseSelector.cls
    - TestCaseSelector.cls
    - CaseService.cls
    - TestCaseService.cls
    - Constants.cls
    - TestDataFactory.cls
# Post-Deployment Manual Steps
None.