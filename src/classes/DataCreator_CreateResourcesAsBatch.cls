global class DataCreator_CreateResourcesAsBatch implements Database.Batchable <ServiceResource>, Database.Stateful{
	Integer Amount;
	double centralLong;
	double centralLat;
	double Radius;
	List<User> usersList;
	String selectedTer;
	

	global DataCreator_CreateResourcesAsBatch(List<User> usersProvided,Integer AmountToCreate, double Rad, Decimal centralLati, Decimal centralLongi, String selectedTerritory) {
		usersList = usersProvided;
		Amount = AmountToCreate;
		centralLat = centralLati;
		centralLong = centralLongi;
		Radius = Rad;
		selectedTer = selectedTerritory;
	}
	

	global List<ServiceResource> start(Database.BatchableContext BC) {
		DataCreatorSet__c currentStatus = DataCreatorController.retreiveCurrentStatusCustomSett();
        currentStatus.CurrentStatus__c = 'Creating Resources';
        update currentStatus;
		List<ServiceResource> resourcesToCreate = new List<ServiceResource>();
		for (User singleUser : usersList){
			ServiceResource sr = new ServiceResource();
			sr.IsActive = true;
			sr.Name = singleUser.Name;
			sr.RelatedRecordId = singleUser.Id;
			sr.ResourceType = 'T';


			resourcesToCreate.add(sr);

		}

		return resourcesToCreate;
	}
	
	
	global void execute(Database.BatchableContext BC, List<ServiceResource> Resources) {
		insert Resources;
		
			// Create STM's
		//DataCreatorSet__c currentStatus = DataCreatorController.retreiveCurrentStatusCustomSett();
  //      currentStatus.CurrentStatus__c = 'Creating Territory Members';
  //      update currentStatus;
		List<ServiceResource> resourcesForSTMs = [select Id from  ServiceResource order by createdDate desc limit :Amount];
		DateTime EffectiveStart = DateTime.now().addDays(-1);
		DateTime EffectiveEnd = DateTime.now().addYears(2);
		ServiceTerritory selectedTerritory = [select Id,Name from ServiceTerritory where Name LIKE :selectedTer ];
		System.debug('Long: ' + centralLong );
		System.debug('Lat: ' + centralLat );
		System.debug('Radius: ' + Radius);
		List<ServiceTerritoryMember> STMsToCreate = new List<ServiceTerritoryMember>();
		for (ServiceResource resourceToCreate : resourcesForSTMs){
			ServiceTerritoryMember newSTM = new ServiceTerritoryMember();
			newSTM.ServiceTerritoryId = selectedTerritory.Id;
			newSTM.ServiceResourceId = resourceToCreate.Id;
			newSTM.EffectiveStartDate = EffectiveStart;
			newSTM.EffectiveEndDate = EffectiveEnd;
			System.debug('Finished regular data /n starting Lat Long calculation');
			if (centralLong != null && centralLat != null) {
				List<Double> results = DataCreatorController.GenerateLatLongWithinCircle(centralLat,centralLong,Radius);
				newSTM.Latitude = results[0];
				newSTM.Longitude = results[1];
			}
			STMsToCreate.add(newSTM);
		}
		insert STMsToCreate;
		


	}


	global void finish(Database.BatchableContext BC) {
		DataCreatorSet__c currentStatus = DataCreatorController.retreiveCurrentStatusCustomSett();
        currentStatus.CurrentStatus__c = 'Completed!';
        update currentStatus;
	}

}