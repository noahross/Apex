public class API_EmailtoSMSLookup
{
    public static String EmailReturn(String cellnumber)
    {
        // Create endpoint and return strings
        String un = '******';
        String pw = '*********';
        String endpoint = 'https://api.data24-7.com/v/2.0?user=' + un + '&pass=' + pw + '&api=T&p1=' + cellnumber;
        String smsemail = '';
        System.Debug('endpoint: ' + endpoint);
        
        // Create HTTP request
        HttpRequest req = new HttpRequest();
        req.setMEthod('GET');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        System.Debug('req.getEndpoint: ' + req.getEndpoint());
        
        // Make request
        Http http = new Http();
        
        HTTPResponse res = new HTTPResponse();
        if(Test.isRunningTest())
        {
            res.setBody('<?xml version="1.0"?><response><results><result item="1"><status>OK</status><number>16025558888</number><wless>y</wless><carrier_name>ATT Mobility</carrier_name><carrier_id>6</carrier_id><sms_address>6025558888@txt.att.net</sms_address><mms_address>6023003657@mms.att.net</mms_address></result></results></response>');
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('Success');
            res.setStatusCode(200);
        }
        else
        {
            // Execute web service call
            res = http.send(req);
        }
        
        System.Debug('res: ' + res);
        System.Debug('Email: ' + res.getBody());
        
        // XML Return should look like this:
        // <?xml version="1.0"?>
        // <response>
        // 	<results>
        // 	 <result item="1">
        // 	  <status>OK</status>
        // 	  <number>160255555555</number>
        // 	  <wless>y</wless>
        // 	  <carrier_name>ATT Mobility</carrier_name>
        // 	  <carrier_id>6</carrier_id>
        // 	  <sms_address>6025555555@txt.att.net</sms_address>
        // 	  <mms_address>6025555555@mms.att.net</mms_address>
        // 	 </result>
        //  </results>
        // </response>
        
        // Parse XML with DOM
        try
        {
            Dom.Document doc = res.getBodyDocument();
            System.Debug('doc: ' + doc);
            
            Dom.XMLNode response = doc.getRootElement();
            Dom.XMLNode results = response.getChildElement('results', null);
            Dom.XMLNode result = results.getChildElement('result', null);
            
            smsemail = result.getChildElement('sms_address', null).getText();
            
            System.Debug('smsemail: ' + smsemail);
            return smsemail;
        }
        
        // Send email on failure (insufficient funds, endpoint changes, etc.)
        catch(System.Exception e)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
            mail.setTargetObjectId('005o0000001geHe');
            mail.setReplyTo('nross@digitalairstrike.com');
            mail.setSenderDisplayName('Data 24-7 API Error Handling');
            mail.setSubject('Data 24-7 API Error');
            mail.setPlainTextBody(e.getMessage() + '\n\n' + res.getBody());
            mail.setSaveAsActivity(false);
                
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            return null;
        }
    }
}