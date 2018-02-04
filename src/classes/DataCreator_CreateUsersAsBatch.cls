global class DataCreator_CreateUsersAsBatch implements Database.Batchable <User>, Database.Stateful{
	Integer Amount;
    String resPrefix;
    String Email;
    

	global DataCreator_CreateUsersAsBatch(Integer AmountToCreate,String resPrfx) {
		Amount = AmountToCreate;
		resPrefix = resPrfx;
		
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



			usersToCreate.add(newUser);
		}

		return usersToCreate;
	}

	global void execute(Database.BatchableContext BC, List<User> Users) {
		
		//insert Users;
	}

	global void finish(Database.BatchableContext BC) {

	}

}