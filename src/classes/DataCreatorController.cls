global class DataCreatorController {
    

    global DataCreatorController() {
    }
    	@RemoteAction
    	global static List<ServiceTerritory> getAllTers()
        {
    		List<serviceTerritory> AllTers = [select Id,Name from ServiceTerritory];
    	return AllTers;
    	}

        @RemoteAction
    	global static Integer getNumOfAvaliableResToCreate()
        {
    		String NumOfAvaliableResToCreate = '0';
    		PermissionSetLicense schedulingPslObject = [SELECT DeveloperName, TotalLicenses,UsedLicenses FROM PermissionSetLicense WHERE  DeveloperName = 'FieldServiceSchedulingPsl'];
            List<Profile> SFLicenses = [Select  Profile.UserLicense.Name,Profile.UserLicense.UsedLicenses,Profile.UserLicense.TotalLicenses From Profile Where Profile.UserLicense.Name = 'Salesforce' limit 1];
    		Integer numOfFreeSchedulingpsls = schedulingPslObject.TotalLicenses - schedulingPslObject.UsedLicenses;
    		System.debug('▒' + schedulingPslObject);
    		System.debug('▒' + numOfFreeSchedulingpsls);
            System.debug('▒ SF Used Licenses: ' + SFLicenses[0].UserLicense.UsedLicenses);
            System.debug('▒ SF Total Licenses: ' + SFLicenses[0].UserLicense.TotalLicenses);
            Integer Used = SFLicenses[0].UserLicense.UsedLicenses;
            Integer Total = SFLicenses[0].UserLicense.TotalLicenses;
            Integer Remaining = Total - Used;
            System.debug('SF Remaining Licenses: ' + Remaining);

    	return Math.min(Remaining, numOfFreeSchedulingpsls);
    	}
    	
    	@RemoteAction
    	global static String CreateResources(Integer numOfUsers, Integer Radius, String Prefix, String serviceTer)
        {
    		DataCreator_CreateUsersAsBatch batch = new DataCreator_CreateUsersAsBatch(numOfUsers,Prefix);
            Database.executeBatch(batch);
            
        return 'Success!';
    	}

}