var app = angular.module('DataCreator', []);
app.controller('FSLDataCreatorController', function($scope, $timeout) {
    "use strict";
    $scope.init=function(){
      $scope.tabClasses=["",""];
      $scope.changeTab(0);
      $scope.working=false;
      $scope.radius = 5;
      $scope.lat = "37.8495233";
      $scope.lng = "-122.4226561";
      $scope.noGeolocation=false;
      $scope.InitialRadius = 0;
      
    }