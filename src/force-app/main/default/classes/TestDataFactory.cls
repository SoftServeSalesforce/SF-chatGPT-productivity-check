@IsTest
public class TestDataFactory {
    public static Account createAccount(Boolean toInsert) {
        Account acc = new Account(
            Name = 'Test Account'
        );
        if (toInsert) {
            insert acc;
        }
        return acc;
    }

    public static Contract createContract(Account acc, Boolean toInsert) {
        Contract contract = new Contract(
            AccountId = acc.Id, 
            StartDate = Date.today(),
            ContractTerm = 12
        );
        if (toInsert) {
            insert contract;
        }
        return contract;
    }

    public static Order createOrder(Account acc, Contract c, Boolean toInsert) {
        Order order = new Order(
            AccountId = acc.Id,
            ContractId = c.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        if (toInsert) {
            insert order;
        }
        return order;
    }
}