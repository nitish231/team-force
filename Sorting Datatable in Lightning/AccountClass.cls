public class AccountClass {
    
    @AuraEnabled
    public static List<Account> getAccountItems() {
        
        List<Account> accountDetails = [Select Id,Name,BillingCity,Phone,AnnualRevenue from Account];
        
        return accountDetails;
        
    }

}