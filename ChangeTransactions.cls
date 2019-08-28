global class ChangeTransactions implements Schedulable {

    public static List<Profile> allProfiles;
    public static List<Id> allUsers;
    public static List<Id> allRecordOwners;
    
    public static void searchAllProfiles() {
        
        allProfiles = [SELECT Id FROM Profile WHERE Name != 'System Administrator'];
    }
    
    public static void searchAllUsers() {
        
        allUsers = new List<Id>();
        
        for (Profile eachProfile: allProfiles) {
            
            allUsers.add(eachProfile.Id);
        }
    }
    
    public static void searchAllRecordOwners() {
        
        allRecordOwners = new List<Id>();
        
        for (User eachUser: [SELECT Id FROM User WHERE ProfileId IN :allUsers]) {
            
            allRecordOwners.add(eachUSer.Id);
        }
    }
    
    public static void deleteDeposits() {
        
        integer recordCount = 0;
	    
	List<Deposit__c> depositsToBeDeleted = new List<Deposit__c>();
        
        for (Deposit__c eachDeposit: [SELECT Name FROM Deposit__c WHERE OwnerId IN :allRecordOwners]) {
            
            depositsToBeDeleted.add(eachDeposit);
            
            recordCount++;
        }
        
        if (recordCount > 0) {
            
            delete depositsToBeDeleted;
        }
    }

    public static void deleteExpenses() {
        
        integer recordCount = 0;
        
        List<Expense__c> expensesToBeDeleted = new List<Expense__c>();
        
        for (Expense__c eachExpense: [SELECT Name FROM Expense__c WHERE OwnerId IN :allRecordOwners]) {
            
            expensesToBeDeleted.add(eachExpense);
            
            recordCount++;
        }
        
        if (recordCount > 0) {
            
            delete expensesToBeDeleted;
        }
    }

    public static void deleteBudgets() {
        
        integer recordCount = 0;
        
        List<Budget__c> budgetsToBeDeleted = new List<Budget__c>();
        
        for (Budget__c eachBudget: [SELECT Name FROM Budget__c WHERE OwnerId IN :allRecordOwners]) {
            
            budgetsToBeDeleted.add(eachBudget);
            
            recordCount++;
        }
        
        if (recordCount > 0) {
            
            delete budgetsToBeDeleted;
        }        
    }    
    
    global static void execute(SchedulableContext runSchedule) {
        
        searchAllProfiles();
        searchAllUsers();
        searchAllRecordOwners();
        
        deleteDeposits();
        deleteExpenses();
        deleteBudgets();
    }
}
