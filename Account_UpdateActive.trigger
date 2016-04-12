trigger Account_UpdateActive on Package_Audit__c (after insert, after update, after undelete, after delete)
{
    // Determine if necessary
    Set<String> stats = new Set<String>{'Active','Pending Cancellation'};
    Set<ID> pIds = new Set<ID>();
    Set<ID> accIds = new Set<ID>();
    Set<String> AccandProd = new Set<String>();
    Set<ID> uaccIds = new Set<ID>();
    Set<String> products = new Set<String>{'SL','RL','SA'};
        
    if(Trigger.IsDelete)
    {
        for(Package_Audit__c p : Trigger.Old)
        {
            uaccIds.add(p.Account__c);
        }
    }
    else
    {
        for(Package_Audit__c p : Trigger.New)
        {
            pIds.add(p.Id);
            if(Trigger.IsUpdate)
            {
                Package_Audit__c oldpa = Trigger.oldmap.get(p.Id);
                if(oldpa.Status__c != p.Status__c && (stats.Contains(oldpa.Status__c) || stats.Contains(p.Status__c)))
                {
                    uaccIds.add(p.Account__c);
                }
            }
            else if(stats.Contains(p.Status__c))
            {
                accIds.add(p.Account__c);
            }
        }
    }
    
    // Update product-specific active fields using Dynamic DML
    if(accIds.Size() > 0 || uaccIds.Size() > 0)
    {
        Map<ID,Account> IDtoAcc = new Map<ID,Account>();
        Map<ID,Package_Audit__c> IDtoPA = new Map<ID,Package_Audit__c>();
        List<Account> allaccs = [SELECT ID,Name,SL_Active__c,RL_Active__c,SA_Active__c FROM Account WHERE ID IN :accIds OR ID IN :uaccIds];
        List<Account> upaccs = new List<Account>();
        Set<ID> upaccIds = new Set<ID>();
        List<Package_Audit__c> allpas = new List<Package_Audit__c>();
        Map<String,Boolean> IDandProd = new Map<String,Boolean>();
        if(uaccIds.Size() > 0)
        {
            allpas = [SELECT ID,Account__c,Status__c,Product__c FROM Package_Audit__c WHERE Account__c IN :uaccIds];
            for(ID i : uaccIds)
            {
                for(String l : products)
                {
                    IDandProd.put(i + ' ' + l,false);
                }
            }
        }
        
        for(Account a : allaccs)
        {
            IDtoAcc.put(a.Id,a);
        }
        if(Trigger.IsInsert || Trigger.IsUndelete)
        {
            for(Package_Audit__c p : Trigger.new)
            {
                if(stats.Contains(p.Status__c))
                {
                    String field = p.Product__c + '_Active__c';
                    IDtoAcc.get(p.Account__c).put(field,true);
                    upaccIds.add(p.Account__c);
                    field = null;
                }
            }
        }
        else
        {
            for(Package_Audit__c p : allpas)
            {
                if(stats.Contains(p.Status__c))
                {
                    IDandProd.put(p.Account__c + ' ' + p.Product__c,true);
                }
            }
            if(IDandProd.size() > 0)
            {
                System.Debug('IDandProd.keySet: ' + IDandProd);
                for(String s : IDandProd.keySet())
                {
                    String d = s.Split(' ')[0];
                    String p = s.Split(' ')[1] + '_Active__c';
                    System.Debug('IDtoAcc.get: ' + d + '.put ' + p + ',' + IDandProd.get(s));
                    IDtoAcc.get(d).put(p,IDandProd.get(s));
                    upaccIds.add(d);
                    d = null;
                    p = null;
                }
            }
        }
        if(upaccIds.Size() > 0)
        {
            for(ID i : upaccIds)
            {
                System.Debug('i: ' + IDtoAcc.get(i));
                upaccs.add(IDtoAcc.get(i));
            }
        }
        if(upaccs.Size() > 0)
        {
            update upaccs;
        }
    }
}