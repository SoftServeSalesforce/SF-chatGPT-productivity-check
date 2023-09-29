public with sharing class AccountHandler {
    public static void handleNew(List<Account> accounts) {
        AccountService.handleNewAccount(accounts[0]);
    }

    public static void handleUpdate(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        for (Id accId : newAccounts.keySet()) {
            Account oldAcc = oldAccounts.get(accId);
            Account newAcc = newAccounts.get(accId);
            AccountService.handleUpdateAccount(oldAcc, newAcc);
        }
    }
}
