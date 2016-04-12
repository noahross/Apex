trigger Site_Activation on Site__c (after update) {
    
    // If the status has changed, query the Activation.
    
    Boolean nec = false;
    Set<ID> sids = new Set<ID>();
    Set<ID> actids = new Set<ID>();
    Map<ID,Site__c> IDtoS = new Map<ID,Site__c>();
    Map<ID,ID> StoA = new Map<ID,ID>();
    Set<ID> userIds = new Set<ID>();
    for(Site__c i : Trigger.new)
    {
        if(i.Activation__c != null)
        {
        	Site__c olds = Trigger.oldMap.get(i.Id);
        	if(i.Stage__c == 'Access Granted' && i.Stage__c != olds.Stage__c)
        	{
            	nec = true;
            	sids.add(i.Id);
                actids.add(i.Activation__c);
            	IDtoS.put(i.Id,i);
            	StoA.put(i.Id,i.Activation__c);
                userIds.add(i.LastModifiedById);
        	}
            olds = null;
        }
    }
    
    if(nec)
    {
        // Map sites to completed date fields and completed by fields.
        Map<String,String> byfields = new Map<String,String>();
    	Map<String,String> datefields = new Map<String,String>();
    	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    	Schema.SObjectType ActSchema = schemaMap.get('Activation__c');
        String qfields = '';
    	Map<String, Schema.SObjectField> fieldMap = ActSchema.getDescribe().fields.getMap();
    	for(String fieldName: fieldMap.keySet())
    	{
	        if(fieldName.contains('_completed_by__c'))
	        {
	            byfields.put(fieldName.Split('_completed_by__c')[0],fieldName);
                qfields += ',' + fieldName;
    	    }
        	else if(fieldName.contains('_completed__c'))
        	{
	            datefields.put(fieldName.Split('_completed__c')[0],fieldName);
                qfields += ',' + fieldName;
	        }
  		}
        
        // Query Activations and Users
        String qu = 'SELECT ID,Name,Account__c' + qfields + ' FROM Activation__c WHERE ID In :actids';
        List<sObject> acts = Database.query(qu);
        Map<ID,sObject> IDtoAct = new Map<ID,sObject>();
        for(sObject a : acts)
        {
            IDtoAct.put(a.Id,a);
        }
        List<User> users = [SELECT ID,Name FROM User WHERE ID In :userIds];
        Map<ID,String> IDtoName = new Map<ID,String>();
        for(User u : users)
        {
            IDtoName.put(u.Id,u.Name);
        }
        
        // Update completion timeline fields with Dynamic DML
        for(Site__c i : Trigger.New)
        {
            if(i.Activation__c != null)
        	{
        		Site__c olds = Trigger.oldMap.get(i.Id);
                if(i.Stage__c == 'Access Granted' && i.Stage__c != olds.Stage__c)
                {
                    IDtoAct.get(i.Activation__c).put(datefields.get(i.Site__c.toLowerCase().Replace('.','_').Replace(' ','_')),System.Now());
                    IDtoAct.get(i.Activation__c).put(byfields.get(i.Site__c.toLowerCase().Replace('.','_').Replace(' ','_')),System.UserInfo.getUserId());
                }
            }
        }
        update acts;
	}

}