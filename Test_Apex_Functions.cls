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
@isTest
public class Test_Apex_Functions {
    
    static testMethod void validateApex_Functions(){
        
        // Create Strings and integer
        String s = ' - 7 - 2016';
        List<String> strs = new List<String>{'Noahs Fictitious Dealership with Additional (Name Length)','Dominate Enhanced with Ad Value for Social Ads'};
        integer maximumlength = 80 - s.length();
        
        // Call method.
        String sname = Apex_Functions.ShortenName(strs,maximumlength);
        System.Assert(sname.length() <= maximumlength);
        sname += s;
        
        // Asserts
        System.Debug('sname: ' + sname);
		System.Assert(sname.length() <= 80);
        System.AssertEquals('Noahs Fictitious Dealership with - Dominate Enhanced with Ad Val - 7 - 2016',sname);
        
        // Add string to list
        strs.add('Noah Ross - Systems and Salesforce Adminstrator Extraordinaire');
        
        sname = Apex_Functions.ShortenName(strs,maximumlength);
        System.Debug('sname: ' + sname);
        System.Assert(sname.length() <= maximumlength);
    }
}