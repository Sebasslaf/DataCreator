  var app = angular.module('DataCreator', []);
  app.controller('FSLDataCreatorController', function($scope, $timeout,$interval) {
    "use strict";
    $scope.init=function(){
      $scope.tabClasses=["",""];
      $scope.changeTab(0);
      $scope.Working= false;
      $scope.CreateWorking= false;
      $scope.SerTerTooltipStatus= false;
      $scope.RadiusToolTipStatus= false;
      $scope.AmountTooltipStatus= false;
      $scope.ResNamePrefixTooltipStatus= false;
      $scope.Ters = [];
      $scope.TerritoryNameModel = "";
      $scope.Amount;
      $scope.GetTers();
      $scope.confirmCreateNotification= false;
      $scope.radius = 5;
      $scope.lat = "37.8495233";
      $scope.lng = "-122.4326561";
      $scope.noGeolocation= false;
      $scope.radius;
      $scope.NumOfLicences = 0;
      $scope.getNumOfAvaliableResToCreate();
      $scope.InitialRadius = 0;
      $scope.addressInput = '';
      $scope.locationButtonStatus = '';
      $scope.createdSuccess = false;
      $scope.ResPrefix = "";
      $scope.initialTer = "";
      $scope.currentBatchStatus = "";
      $scope.currentStatusPlaceHolder = "Create Resources!";
      $scope.stopPolling = false;
    }

  // Tab Navigation
  $scope.changeTab=function(tabIndex){
     if($scope.working){
      return;
    }
    $scope.showTab=tabIndex;
    for(var i=0; i<$scope.tabClasses.length; i++){
      if(i==tabIndex){
        $scope.tabClasses[i]="slds-active";
        $timeout(function() {
          google.maps.event.trigger(map, "resize");
        }, 40)
      }
      else{
        $scope.tabClasses[i]="";
        $scope.MapInit();
      }
    }
  }
      // Load Service Territories to Picklist
  $scope.GetTers = function () {
    var initialTer = '';
    Visualforce.remoting.Manager.invokeAction(
      RemoteActions.getAllTers,
      function(lstTers, ev){
      if(ev.statusCode!=200){
        console.log("Error loading locations:" +ev);
      }
      else{
        console.log("Loaded Locations");
        console.log(lstTers);
        $scope.Ters = lstTers;
        $scope.initialTer = $scope.Ters[0]; 
        console.log(initialTer);
        $scope.$apply();
      }
    })
  };

      
    
    // Map
  $scope.MapInit = function(){
    var myCenter = new google.maps.LatLng($scope.lat, $scope.lng);
    var map = new google.maps.Map(document.getElementById('map'), {
      zoom: 12,
      center: myCenter,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })
    $scope.mapInstance=map;
    map.setOptions({ disableDoubleClickZoom: true });
    var input = (document.getElementById('address-input'));
    var searchBox = new google.maps.places.SearchBox(input);
    map.addListener('bounds_changed', function() {
      searchBox.setBounds(map.getBounds());
    });
    searchBox.addListener('places_changed', function() {
      var places = searchBox.getPlaces();
      if (places.length == 0) {
        return;
      }
      else{
        var ll = new google.maps.LatLng(places[0].geometry.location.lat(), places[0].geometry.location.lng());
        $scope.UpdateMap(ll);
        $scope.UpdateAddress(ll);      
      }
      //google.maps.event.trigger($scope.mapInstance, 'resize');
  });

          //Adding event listener for double click on map
          map.addListener('dblclick', function(event){
            if($scope.noGeolocation) return;
            var ll = new google.maps.LatLng(event.latLng.lat(), event.latLng.lng(), true);
            $scope.UpdateMap(ll);
            $scope.UpdateAddress(ll);
          });
      }

      $scope.UpdateMap = function (latlng) {
        $scope.selectedLat = latlng.lat();
        $scope.selectedLong = latlng.lng();
        if ($scope.marker == undefined) {
          $scope.marker = new google.maps.Marker({
            position: latlng,
            map: $scope.mapInstance,
            animation: google.maps.Animation.DROP,
          });
          $scope.CreateOrUpdateCircle(latlng);
        }
        else {
          $scope.marker.setAnimation(google.maps.Animation.DROP);
          $scope.marker.setPosition(latlng);
          $scope.mapInstance.setCenter($scope.marker.getPosition());
          $scope.CreateOrUpdateCircle(latlng);
        }
        
        

        
      }

      $scope.UpdateAddress = function(latlng){
          //Updating the placeholder field with the address
          var geoCoder = new google.maps.Geocoder();
          geoCoder.geocode({ 'latLng': latlng }, function (response, y) {
            if (y = "OK") {
              if (response.length != 0) {
                (document.getElementById('address-input')).value = response[0].formatted_address;
                $scope.$apply();
              }
            }
      });
          
      }
       //update Radius
          $scope.updateRadius  = function(val){
              $scope.radius = val;
              if ($scope.marker)
                $scope.CreateOrUpdateCircle($scope.marker.getPosition());

            
          }
          

      // Get Current Status From private setting
        $scope.GetCurrentBatchStatus = function(){
          Visualforce.remoting.Manager.invokeAction(
          RemoteActions.retreiveCurrentStatus,
          function(retreivedStatus,ev){
            if(ev.statusCode!=200){
        console.log("Error getting current status");
            }
            else {
            $scope.currentStatusPlaceHolder = retreivedStatus;
            console.log('currentBatchStatus is: ' + $scope.currentStatusPlaceHolder);
            }
          })
        }

      // Get number of free licenses
      $scope.getNumOfAvaliableResToCreate = function () {
      Visualforce.remoting.Manager.invokeAction(
      RemoteActions.getNumOfAvaliableResToCreate,
      function(numOfFreeLicences, ev){
        if(ev.statusCode!=200){
        console.log("Error Getting num of free licences");
        }
        else {
        $scope.NumOfLicences = numOfFreeLicences;
        console.log(' getNumOfAvaliableResToCreate have Run');
        console.log($scope.NumOfLicences);
        $scope.LicenseNumberplacehold = $scope.NumOfLicences;
        $scope.$apply();
        }
      })
    };


    
    // $scope.FinishedWork = function(){
    //   setTimeout(function(){$scope.CreateWorking=false;}, 5000);
    // }

    // Call Create Resources Method
    $scope.CreateResources = function(Amount,radius,ResPrefix,serviceTer,lat,lng){
      var interval = $interval($scope.GetCurrentBatchStatus, 200, 200 );
      $scope.CreateWorking=true;
      // Visualforce.remoting.Manager.invokeAction(
      // RemoteActions.CreateResources,$scope.Amount, $scope.radius, $scope.ResPrefix, $scope.initialTer.Name, $scope.circle.getCenter().lat(), $scope.circle.getCenter().lng(),
      // function(msg,ev){
      //   }, {escape: false})
      }


/////////////////////////////////////////
      
   // Create Or Update Circle
  $scope.CreateOrUpdateCircle = function(latlng){
    if ($scope.circle == undefined) {
        $scope.circle = new google.maps.Circle({
          center: latlng,
          map: $scope.mapInstance,
          radius: $scope.radius * 1000,
          fillColor: '#23D452',
          fillOpacity: 0.4,
          strokeColor: '#20873C',
          strokeOpacity: 0.7,
          editable: false,
          strokeWeight: 0.5
    });
    console.log('Current position' + $scope.circle.getCenter());
    }
    else
    {
      $scope.circle.setCenter(latlng);
      $scope.circle.setRadius($scope.radius * 1000);
      console.log('Current position' + $scope.circle.getCenter());
      }
  };
});