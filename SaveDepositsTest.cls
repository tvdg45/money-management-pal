@isTest
public class SaveDepositsTest {

    @testSetup static void insertTestRecords() {
        
        //Deposits to insert
        List<Deposit__c> depositsToInsert = new List<Deposit__c>();
        
        //Insert associated budget
        Budget__c newBudget = new Budget__c(Name = 'Entertainment', Amount__c = 100);
        
        insert newBudget;
        
        //Search associated budget
        Budget__c thisBudget = [SELECT Id FROM Budget__c LIMIT 1];
        
        //Insert test deposits
        for (integer i = 0; i < 200; i++) {
            
            Deposit__c newDeposit = new Deposit__c(Name = 'Deposit ' + i, Month__c = 'July', Amount__c = 100,
                                                  Category__c = thisBudget.Id);
            
            depositsToInsert.add(newDeposit);
        }
        
        insert depositsToInsert;
    }
    
    //Make sure each associated transaction is updated
    //when a deposit is updated.
    @isTest static void updateTransaction() {
        
        List<Deposit__c> depositsToUpdate = new List<Deposit__c>();
        
        Test.startTest();
        
        for (Deposit__c eachDeposit: [SELECT Amount__c FROM Deposit__c]) {
            
            eachDeposit.Amount__c = 500;
            
            depositsToUpdate.add(eachDeposit);
        }
        
        update depositsToUpdate;
        
        Test.stopTest();
        
        integer allTransactions = [SELECT Count() FROM Transaction__c WHERE Amount__c = 500];
        
        System.assertEquals(200, allTransactions);
    }
    
    //Make sure each associated transaction is deleted
    //when a deposit is deleted.
    @isTest static void deleteTransaction() {

        List<Deposit__c> depositsToDelete = new List<Deposit__c>();
        
        Test.startTest();
        
        for (Deposit__c eachDeposit: [SELECT Amount__c FROM Deposit__c]) {
            
            depositsToDelete.add(eachDeposit);
        }
        
        delete depositsToDelete;
        
        Test.stopTest();
        
        integer allTransactions = [SELECT Count() FROM Transaction__c];
        
        System.assertEquals(0, allTransactions);        
    }
}
