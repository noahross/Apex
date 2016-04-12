/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class Test_Maintenance_DeleteOldRecords {
    
    static testMethod void Validate_Maintenance_DeleteOldRecords() {
        
        // Create Tasks and Product Activity Summaries that trigger To_Delete__c ('9999999999').
        Account acc = new Account(Name = 'Noahs Fictitious Dealership');
        insert acc;
        List<Task> tasks = new List<Task>();
        List<Product_Activity_Summary__c> pas = new List<Product_Activity_Summary__c>();
        Task t = new Task(Subject = 'Test Activity',logmein__CField1__c = '9999999999',Status = 'New');
        Task u = new Task(Subject = 'Test Activity',logmein__CField1__c = '99999999',Status = 'New');
        tasks.add(t);
        tasks.add(u);
        Product_Activity_Summary__c pb = new Product_Activity_Summary__c(Account__c = acc.Id,Product_Activity_Summary_Id__c = '99999999999999999999999999999',Dummy__c = '99999999');
        pas.add(pb);
        insert tasks;
        insert pas;
		
        // Call Maintenance_DeleteOldRecords
        Test.startTest();
        Maintenance_DeleteOldRecords mdo = new Maintenance_DeleteOldRecords();
        Database.executeBatch(mdo);
        Test.stopTest();
        
        // Test Deletion
        tasks = [SELECT ID,To_Delete__c FROM Task];
        pas = [SELECT ID,To_Delete__c FROM Product_Activity_Summary__c];
        System.assertEquals(1,tasks.size());
        System.assertEquals(1,pas.size());
        System.assert(pas[0].To_Delete__c == false);
        System.assert(tasks[0].To_Delete__c == false);
    }
	
}