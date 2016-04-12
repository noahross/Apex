global class Apex_Functions {
    
    // ShortenName method accepts a list of 2 strings (i.e. AccountName + PackageName, or AccountName + Subject, etc.)
    // and an integer representing the maximum length (i.e. 80 - additional static text for standard name fields).
    
    global static String ShortenName(List<String> strs,integer maximumlength)
    {
        if(maximumlength < 1)
        {
            maximumlength = 80;
        }
        String sname = '';
        for(String s : strs)
        {
            sname += s;
            if(s != strs[strs.Size()-1])
            {
                sname += ' - ';
            }
        }
        
        if(sname.length() > maximumlength)
        {
            String saccname = '';
            String addname = '';
            Boolean paren = true;
            Boolean accg = true;
            Boolean addg = true;
            Boolean allelse = true;
            
            // If more than two strings received, combine strings, else assign account name and additional
            if(strs.Size() > 2)
            {
                sname = '';
                integer l = maximumlength / strs.Size();
                for(integer i=0;i<strs.Size();i++)
                {
                    if(i>0)
                    {
                        sname += ' - ';
                    }
                    sname += strs[i].substring(0,l-4);
                }
            }
            else
            {
                saccname = strs[0];
                addname = ' - ' + strs[1];
            }
            
            // Try shortening techniques in order
            while(sname.length() > maximumlength)
            {
            	
            	// Remove parentheticals from account name
                if(saccname.Contains(' (') && paren)
                {
                    System.Debug('before paren saccname: ' + saccname);
                    saccname = saccname.Split(' \\(')[0];
                    System.Debug('after paren saccname: ' + saccname);
                    sname = saccname + addname;
                    paren = false;
                }
                
                // Reduce account name to 32 characters
                else if(saccname.length() > maximumlength/strs.Size() && accg)
                {
                    System.Debug('before nameg saccname: ' + saccname);
                    saccname = saccname.substring(0,32);
                    System.Debug('after nameg saccname: ' + saccname);
                    sname = saccname + addname;
                    accg = false;
                }
                
                // Reduce additional text to 32 characters
                else if(addname.length() > maximumlength/strs.Size() && addg)
                {
                    System.Debug('before packg addname: ' + addname);
                    addname = addname.substring(0,32);
                    System.Debug('after packg addname: ' + addname);
                    sname = saccname + addname;
                    addg = false;
                }
                
                // Reduce combined name to maximum length
                else
                {
                    System.Debug('before allelse sname: ' + sname);
                    sname = sname.substring(0,maximumlength);
                    System.Debug('after allelse sname: ' + sname);
                }
            }
        }
        System.Debug('final sname: ' + sname);
        return sname;
    }
    
}