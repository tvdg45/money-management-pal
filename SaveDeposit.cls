global class SaveDeposit implements Database.Batchable<sObject>, Database.Stateful {

    global String action;
    global List<Deposit__c> allDeposits;
    
    global Database.QueryLocator start(Database.BatchableContext batchQuery) {
        
        //Get all records if the action is 'delete'
        //Get only records by child id if the action is 'update'
        if (action == 'delete') {

        	return Database.getQueryLocator('SELECT Name, Month__c, Type__c, Amount__c, ' +
                                        'Category__c FROM Transaction__c ' +
                                        'ORDER BY CreatedDate DESC');            
        } else {

        	return Database.getQueryLocator('SELECT Name, Month__c, Type__c, Amount__c, ' +
                                        'Category__c FROM Transaction__c WHERE Deposit__c IN :allDeposits ' +
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
                
        		//Because the lookup field, 'Deposit__c', has no value
        		//searching by that field in the Transaction__c would have no positive match.
        		//This is why it is easier to see if the 'Deposit__c' is null, before deleting a record.
                if (eachTransaction.Deposit__c == null && eachTransaction.Expense__c == null) {
                    
                    transactionsToProcess.add(eachTransaction);
                }
            }
            
            delete transactionsToProcess;            
        } else {
            
        	//List of deposits to update each transaction
        	List<Deposit__c> allDeposits = [SELECT Name, Month__c, Amount__c,
                                        Category__c FROM Deposit__c WHERE Id IN :allDeposits
                                        ORDER BY CreatedDate DESC];
            
            //This loop updates the associated transactions with deposit field values.
            for (Transaction__c eachTransaction: allTransactions) {

                eachTransaction.Name = allDeposits[i].Name;
                eachTransaction.Month__c = allDeposits[i].Month__c;
				eachTransaction.Amount__c = allDeposits[i].Amount__c;
                eachTransaction.Category__c = allDeposits[i].Category__c;
                
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
