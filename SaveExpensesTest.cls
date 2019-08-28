@isTest
public class SaveExpensesTest {

    @testSetup static void insertTestRecords() {
        
        //Expenses to insert
        List<Expense__c> expensesToInsert = new List<Expense__c>();
        
        //Insert associated budget
        Budget__c newBudget = new Budget__c(Name = 'Entertainment', Amount__c = 100);
        
        insert newBudget;
        
        //Search associated budget
        Budget__c thisBudget = [SELECT Id FROM Budget__c LIMIT 1];
        
        //Insert test expenses
        for (integer i = 0; i < 200; i++) {
            
            Expense__c newExpense = new Expense__c(Name = 'Expense ' + i, Month__c = 'July', Amount__c = 100,
                                                   Type__c = 'Purchase', Category__c = thisBudget.Id);
            
            expensesToInsert.add(newExpense);
        }
        
        insert expensesToInsert;
    }
    
    //Make sure each associated transaction is updated
    //when a expense is updated.
    @isTest static void updateTransaction() {
        
        List<Expense__c> expensesToUpdate = new List<Expense__c>();
        
        Test.startTest();
        
        for (Expense__c eachExpense: [SELECT Amount__c FROM Expense__c]) {
            
            eachExpense.Amount__c = 500;
            
            expensesToUpdate.add(eachExpense);
        }
        
        update expensesToUpdate;
        
        Test.stopTest();
        
        integer allTransactions = [SELECT Count() FROM Transaction__c WHERE Amount__c = 500];
        
        System.assertEquals(200, allTransactions);
    }
    
    //Make sure each associated transaction is deleted
    //when a expense is deleted.
    @isTest static void deleteTransaction() {

        List<Expense__c> expensesToDelete = new List<Expense__c>();
        
        Test.startTest();
        
        for (Expense__c eachExpense: [SELECT Amount__c FROM Expense__c]) {
            
            expensesToDelete.add(eachExpense);
        }
        
        delete expensesToDelete;
        
        Test.stopTest();
        
        integer allTransactions = [SELECT Count() FROM Transaction__c];
        
        System.assertEquals(0, allTransactions);        
    }
}
