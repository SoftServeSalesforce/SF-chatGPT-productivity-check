Change Description:

Created class UsersSelector to return Users status(Active/Inactive) to use in CaseService class. Edited ‘preventStatusChangeByNotAnOwner’ method on CaseService to prevent logged in User to edit Status field if owner Is Active. Edited Test classes to accomodate new changes on caseService for ‘preventStatusChangeByNotAnOwner’.  Created new Test classes as TestDataFactory and TestUsersSelector.

-----------------------
Pre-deployment steps:

No pre-deployment Activities

------------------------
Metadata changes listing:

Classes:
-UsersSelector
-CaseService
-Constants
-TestDataFactory
-TestUsersSelector
-TestCaseService

-----------------------
Post deployment:

No post Deployment activities
