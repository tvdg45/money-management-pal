global class SaveExpense implements Database.Batchable<sObject>, Database.Stateful {

    global String action;
    global List<Expense__c> allExpenses;
    
    global Database.QueryLocator start(Database.BatchableContext batchQuery) {
        
        //Get all records if the action is 'delete'
        //Get only records by child id if the action is 'update'
        if (action == 'delete') {

        	return Database.getQueryLocator('SELECT Name, Month__c, Type__c, Amount__c, ' +
                                        'Category__c FROM Transaction__c ' +
                                        'ORDER BY CreatedDate DESC');            
        } else {

        	return Database.getQueryLocator('SELECT Name, Month__c, Type__c, Amount__c, ' +
                                        'Category__c FROM Transaction__c WHERE Expense__c IN :allExpenses ' +
                                        'ORDER BY CreatedDate DESC');            
        }
    }
    
    global void execute(Database.BatchableContext batchQuery, List<Transaction__c> allTransactions) {
        
        //Index of record being processed
        Integer i = 0;
        
        //Process a batch of transactions
        List<Transaction__c> transactionsToProcess = new List<Transaction__c>();
        
        if (action == 'delete') {

            for (Transaction__c eachTransaction: [SELECT Deposit__c, Expense__c FROM Transaction__c ORDER BY CreatedDate DESC]) {
                
        		//Because the lookup field, 'Expense__c', has no value
        		//searching by that field in the Transaction__c would have no positive match.
        		//This is why it is easier to see if the 'Expense__c' is null, before deleting a record.
                if (eachTransaction.Deposit__c == null && eachTransaction.Expense__c == null) {
                    
                    transactionsToProcess.add(eachTransaction);
                }
            }
            
            delete transactionsToProcess;            
        } else {
            
        	//List of expenses to update each transaction
        	List<Expense__c> allExpenses = [SELECT Name, Month__c, Amount__c,
                                        Category__c, Type__c FROM Expense__c WHERE Id IN :allExpenses
                                        ORDER BY CreatedDate DESC];
            
            //This loop updates the associated transactions with expense field values.
            for (Transaction__c eachTransaction: allTransactions) {

                eachTransaction.Name = allExpenses[i].Name;
                eachTransaction.Month__c = allExpenses[i].Month__c;
				eachTransaction.Amount__c = 0 - allExpenses[i].Amount__c;
                eachTransaction.Category__c = allExpenses[i].Category__c;
                eachTransaction.Type__c = allExpenses[i].Type__c;
                
                transactionsToProcess.add(eachTransaction);
                
                i++;
            }
            
            update transactionsToProcess;
        }        
    }
    
    global void finish(Database.BatchableContext batchQuery) {
        
        List<AsyncApexJob> job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id = :batchQuery.getJobId()];
		
        if (job.size() > 0) {
            
            if (job.size() == 1) {
                
                System.debug(job.size() + ' record processed');
            } else {
                
                System.debug(job.size() + ' records processed');
            }
        }      
    }
}
