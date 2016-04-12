global class Maintenance_DeleteOldRecords implements database.Batchable<String>,Database.Stateful
{
	// This class will delete any records from designated objects
	// where the To_Delete__c formula field evaluates to true.
	
    // Boolean to determine if batch must run again due to too many records.
    global boolean bReRun = false;
    
    // List of sObject names
    global Iterable<String> start(Database.BatchableContext ctx)
    {
        return new List<String>{'Product_Activity_Summary__c','Task','APEX_Email__c'};
    }
    
	global void execute(Database.BatchableContext ctx, List<String> lstsObjectName)
    {
        List<sObject> lstDeleteRecords = new List<sObject>();
        for(String strObjectName : lstsObjectName)
        {
            for(sObject objsObject : database.query('SELECT ID FROM ' + strObjectName + ' WHERE To_Delete__c = TRUE'))
            {
                if(lstDeleteRecords.size() < 9998)
                {
                    lstDeleteRecords.add(objsObject);
                }
                else
                {
                    bReRun = true;
                    break;
                }
            }
        }
        
        // Sort list by sObject, because DML can't execute unsorted
        lstDeleteRecords.sort();
        delete lstDeleteRecords;
    }
    global void finish(Database.BatchableContext ctx)
    {
        if(bReRun)
        {
            System.Debug('Running Delete Again.');
            Database.executebatch(new Maintenance_DeleteOldRecords());
        }
    }
}