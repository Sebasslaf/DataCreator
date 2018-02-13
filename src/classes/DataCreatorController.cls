public class DataCreatorController {
    

    public DataCreatorController() {
        
    }
    
    	@RemoteAction
    	public static List<ServiceTerritory> getAllTers()
        {
    		List<serviceTerritory> AllTers = [select Id,Name from ServiceTerritory];
    	return AllTers;
    	}

        @RemoteAction
    	public static Integer getNumOfAvaliableResToCreate()
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
    	public static String CreateResources(Integer numOfUsers, Double Radius, String Prefix, String serviceTer,Decimal centralLat, Decimal centralLong)
        {   
            DataCreatorSet__c currentStatus = retreiveCurrentStatusCustomSett();
            currentStatus.CurrentStatus__c = 'Preparing Data';
            update currentStatus;

    		DataCreator_CreateUsersAsBatch batch = new DataCreator_CreateUsersAsBatch(numOfUsers,Prefix,centralLat,centralLong,Radius,serviceTer);
            Database.executeBatch(batch,50);
            
            
        return 'Success!';
    	}
        public static List<Double> GenerateLatLongWithinCircle (Decimal LatCenter , Decimal LongCenter, double rad)
        {
            List<Double> results = new List<Double>();
            Decimal radiusInDegrees = rad / 111.0;
            Decimal u = Math.random();
            Decimal v = Math.random();
            Decimal w = radiusInDegrees * Math.sqrt(u);
            Decimal t = 2 * Math.PI * v;
            Decimal x = w * Math.cos(t);
            Decimal y = w * Math.sin(t);  
            
            double new_x = x / Math.cos(LongCenter);
            Decimal foundLongitude = new_x + LongCenter;
            Decimal foundLatitude = y + LatCenter;
            System.debug('Longitude: ' + foundLongitude + '  Latitude: ' + foundLatitude );
            results.add(foundLatitude);
            results.add(foundLongitude);
            return results;
        }
        @RemoteAction
        public static String retreiveCurrentStatus (){
            DataCreatorSet__c CurrentStatusObj = DataCreatorSet__c.getInstance('CurrentStatus');
            return CurrentStatusObj.CurrentStatus__c;
          
        }
        public static void changeCurrentStatusSetting(String CurrentStatus,Id currentBatchId){

        }
        public static DataCreatorSet__c retreiveCurrentStatusCustomSett(){
            DataCreatorSet__c CurrentStatusObj = DataCreatorSet__c.getInstance('CurrentStatus');
            //if (CurrentStatusObj.CurrentStatus__c == null)
            //    DataCreatorSet__c CurrentStatusSet = new DataCreatorSet__c('CurrentStatus');
            
            return CurrentStatusObj;
        }
        
               
}

