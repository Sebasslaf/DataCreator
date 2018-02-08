global class DataCreator_CreateUsersAsBatch implements Database.Batchable <User>, Database.Stateful{
	Integer Amount;
    String resPrefix;
    String Email;
    double Radiuss;
    Decimal centralLat;
    Decimal centralLong;
    String selectedTerritory;
    

	global DataCreator_CreateUsersAsBatch(Integer AmountToCreate,String resPrfx,Decimal centralLati,Decimal centralLongi,double Radius,String SelectedTer) {
		Amount = AmountToCreate;
		resPrefix = resPrfx;
		centralLat = centralLati;
		centralLong = centralLongi;
		Radiuss = Radius;
		selectedTerritory = SelectedTer;


		
	}

	global List<User> start(Database.BatchableContext BC) {
		//List<ServiceTerritory> SerTer = [select Id,Name from ServiceTerritory where Name = :selectedTer];
		//System.debug('SelectedTer is: ' + SerTer[0].Name);
		Profile profileId = [select Id from Profile where Name LIKE '%Standard User%'];
		
		System.debug('User Create Batch Executed');
		System.debug('The following Data Was Received: ');
		System.debug(Amount + ', ' + resPrefix);

		if (resPrefix == ''){
			resPrefix = 'ResourceDefault';
		}
		List<User> usersToCreate = new List<User>();
		for (Integer i=1;i<Amount+1;i++){
			User newUser = new User();
			newUser.LastName = 'DC_'+resPrefix+'#' + i;
			newUser.Email = resPrefix + i + '@gmail.DataCreate';
			newUser.UserName = resPrefix + i + '@gmail.UserName';
			newUser.Alias = 'DC';
			newUser.LocaleSidKey = 'en_US';
			newUser.ProfileId = profileId.id;
			newUser.EmailEncodingKey = 'UTF-8';
			newUser.TimeZoneSidKey = 'GMT';
			newUser.LanguageLocaleKey = 'en_US';
			newuser.USERPERMISSIONSSFCONTENTUSER = False;


			usersToCreate.add(newUser);
		}

		return usersToCreate;
	}

	global void execute(Database.BatchableContext BC, List<User> Users) {
		List<PermissionSet> schedulingPsl = [select Id from PermissionSet where name LIKE '%FSL_Resource_License%' OR name 
							LIKE '%FSL_Resource_Permissions%'];

		insert Users;
		List<User> usersToAssign = [select Id,Name from User order by createdDate desc limit :Amount];
		List<PermissionSetAssignment> newPSAs = new List<PermissionSetAssignment>();
		for (User s : usersToAssign){
			PermissionSetAssignment psa1 = new PermissionSetAssignment();
			psa1.AssigneeId = s.Id;
			psa1.PermissionSetId = schedulingPsl[0].Id;
			newPSAs.add(psa1);
		}

		for (User q : usersToAssign){
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = q.Id;
			psa.PermissionSetId = schedulingPsl[1].Id;
			newPSAs.add(psa);
		}
		insert newPSAs;

	}

	global void finish(Database.BatchableContext BC) {
		List<User> usersToCreateResources = [select Id,Name from User order by createdDate desc limit :Amount];
		DataCreator_CreateResourcesAsBatch batch = new DataCreator_CreateResourcesAsBatch(usersToCreateResources,Amount,Radiuss,centralLat,centralLong,selectedTerritory);
        Database.executeBatch(batch,50);

	}

}