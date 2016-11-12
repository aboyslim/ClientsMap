<%@ Page Title="" Language="C#" MasterPageFile="~/ClientVisitMapMaster.Master" AutoEventWireup="true" CodeBehind="TodaysSchedule-local.aspx.cs" Inherits="ClientVisitMap.TodaysSchedule" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <script type="text/javascript">

        var map; //map variable used throughout the project
        var infoWindow; //infoWindow variable  

        //var markerCluster; //MarkerClusterer object (if used)

        //OverlappingMarkerSpiderfier
        var oms;

        //array to hold client markers   
        var clientArrMarkers = [];     

        //Only need when geocoding
        var geocoder = new google.maps.Geocoder();                  
        
        //variable with all the table data
        var todaysSchedule = JSON.parse('<%= getTodaysSchedule() %>'); 
        
        //Default Map Settings
        var zoom = 4;
        var center = new google.maps.LatLng(37.429142, -85.529980); //Static center of where all markers can be shown
        cnsltMapOptions = {//Settings for map
            center: center,
            zoom: zoom,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                position: google.maps.ControlPosition.RIGHT_BOTTOM,
                index: 3
            },
        };

        var clHtml;//html string for client infoWindow
        var chkList; //Variable to hold cnslt checkBoxList
        var checkbox; //each checkbox in cnslt checkBoxList
        var button; //variable to store Show/clear All button

        var clientIcon, geocodeIcon;
        var nextAddress = 0;
        var delay = 100;
        var counter = 0;
        //var latLng;
        //var testDateStr = "2015-11-04T00:00:00.000";
        //var testDate = new Date(testDateStr);
        var listBoxCount;


        //Main function that loads the map, controls and settings
        function load() {                    
            
            //Create map
            map = new google.maps.Map(document.getElementById("map"), cnsltMapOptions); //End Map Variable

            infoWindow = new google.maps.InfoWindow; //InfoWindow object

            oms = new OverlappingMarkerSpiderfier(map);

            //oms.addListener('click', function (marker, map, infoWindow, html, event)
            //{
            //    infoWindow.setContent(html);
            //    infoWindow.open(map, marker);
            //});
            
            //Closes current InfoWidnow when clicked on map
            google.maps.event.addListener(map, "click", function () {
                infoWindow.close();
            });

            oms.addListener('spiderfy', function(markers) {
                infoWindow.close();
            });


            //--------------------CLIENTS--------------------------------------------------------------------                      

            var schdlCount = <%= schdlCount %>;
            
            //create icon to display green pin as marker
            clientIcon = new google.maps.MarkerImage('Images/clientpin-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );           

            
            geocodeIcon = new google.maps.MarkerImage('Images/clientpin.png',
                               new google.maps.Size(40, 40),
                               new google.maps.Point(0, 0),
                               new google.maps.Point(19, 39)
                               );

            //-------------------------------------------DISPLAY MARKERS FOR TODAYSSCHEDULE DATABASE-----------------------------------------------------------------------
            for (var schdlIndx = 0; schdlIndx < schdlCount; schdlIndx++)
            {        
                var schdlData = todaysSchedule[schdlIndx];
                var schdleName = schdlData.schdlCmpName;
                var member = schdlData.schdlCmpMembId;
                var schdlAddress = todaysSchedule[schdlIndx].schdlCmpAddr1 + ", " + todaysSchedule[schdlIndx].schdlCity + ", " + todaysSchedule[schdlIndx].schdlState + " " + todaysSchedule[schdlIndx].schdlZip;
                var start = schdlData.schdlStart;
                var end = schdlData.schdlEnd;
                var startStr = new Date(parseInt(todaysSchedule[schdlIndx].schdlStart.substr(6)));
                var endStr = new Date(parseInt(todaysSchedule[schdlIndx].schdlEnd.substr(6)));
                var serviceID = schdlData.schdlServiceId;
                var summary = schdlData.schdlSumm;
                var scheduleAddrId = schdlData.schdlAddrId;
                var schdlLat = schdlData.llLat;
                var schdlLng = schdlData.llLng;
                clHtml = "<b>" + schdleName + "</b> <br />" 
                        + member + "<br /> "
                        + "<br />" + schdlAddress + "<br />"
                        + startStr 
                        + " - " + endStr + "<br /> Service ID: "
                        + serviceID + "<br />" 
                        + summary; //html to display in infoWindow
           
                //if(startStr <= testDate || endStr >= testDate)
                //{  
                if (schdlLat !== null && schdlLng !== null){

                    var latLng = new google.maps.LatLng(schdlLat, schdlLng);                            
                            
                    //Create client marker
                    var clientMarker = new google.maps.Marker({
                        map: map,
                        position: latLng,
                        title: schdleName,
                        icon: clientIcon
                    });

                    bindInfoWindow(clientMarker, map, infoWindow, clHtml); 

                    //Add displayed markers into array of markers
                    clientArrMarkers.push(clientMarker);      
                    oms.addMarker(clientMarker);
                } 

                //Center the map to show all markers on load
                var bounds = new google.maps.LatLngBounds();
                for (var k = 0; k < clientArrMarkers.length; k++) {
                    bounds.extend(clientArrMarkers[k].getPosition());                    
                }           
                //}       
            }        
            //----------------------------------------------------------------------------------------------------------------------------------
                      
            map.fitBounds(bounds); //Center the map to show all markers on load
            
            // Create the DIV to hold the control and call the CenterControl() constructor
            // passing in this DIV.
            var centerControlDiv = document.createElement('div');
            var centerControl = new CenterControl(clientArrMarkers, centerControlDiv, map, new google.maps.LatLng(38.226402, -89.666464));
            centerControlDiv.index = 1;
            centerControlDiv.style['padding-top'] = '10px';
            map.controls[google.maps.ControlPosition.TOP_CENTER].push(centerControlDiv);
            //--------------------END CLIENTS--------------------------------------------------------------------
                
            //Resize Function
            google.maps.event.addDomListener(window, "resize", function() {
                var center = map.getCenter();
                google.maps.event.trigger(map, "resize");
                map.setCenter(center);
            });

            google.maps.event.addDomListener(window, 'load', load);

        }//END LOAD-------------------------------------------------------------------------------------
        
      
        //CENTERS ON CLIENT WHEN CLICKED ON IN LISTBOX
        function centerClient(){
            listBoxCount = <%= bxCount %>;

            var clientList = document.getElementById('<%=clientListBox.ClientID%>');

            for(var i = 0; i < clientList.length; i++)
            {                                
                if (clientList.options[i].selected)
                {                 
                    for (var j = 0; j < listBoxCount; j++)
                    {                        
                        if (clientList.options[i].value == todaysSchedule[j].schdlCmpName)
                        {
                            var point = new google.maps.LatLng(todaysSchedule[j].llLat, todaysSchedule[j].llLng);
                            map.setCenter(point);
                            if (map.getZoom() < 16){map.setZoom(18);}
                            infoWindow.setContent("<b>" + todaysSchedule[j].schdlCmpName + "</b> <br />Click pin for details.");
                            infoWindow.open(map, clientArrMarkers[j]);
                            clientArrMarkers[j].setTitle("Click for details");
                        }                        
                    }
                }                    
            }                
        }
            

        
        //Control to set buttons on map and have them zoom into different regions/region webpages
        function CenterControl(array, controlDiv, map, center) {

            // We set up a variable for this since we're adding event listeners later.
            var control = this;

            // Set the center property upon construction
            control.center_ = center;
            controlDiv.style.clear = 'both';

            //Region center geocodes
            var houston = new google.maps.LatLng(29.76328, -95.36327),
                woodlands = new google.maps.LatLng(30.182951, -95.522478),
                austin = new google.maps.LatLng(30.463839, -97.692977),
                midland = new google.maps.LatLng(32.022167, -102.115028),
                dallas = new google.maps.LatLng(32.996748, -96.770978),
                milwaukee = new google.maps.LatLng(43.007959, -87.972956),
                easton = new google.maps.LatLng(40.930474, -75.877147),
                miramar = new google.maps.LatLng(26.160767, -80.255029),
                unitedstates = new google.maps.LatLng(39.086254, -94.578501),
                dubai = new google.maps.LatLng(25.110001, 55.252296);


            //US BUTTON-----------------------------------------
            // Set CSS for the control border
            var usCenterUI = document.createElement('div');
            usCenterUI.id = 'UI';
            usCenterUI.title = 'Click to recenter to US';
            controlDiv.appendChild(usCenterUI);

            // Set CSS for the control interior
            var usCenterText = document.createElement('div');
            usCenterText.id = 'UIText';
            usCenterText.innerHTML = 'United States';
            usCenterUI.appendChild(usCenterText);

            // Set up the click event listener for controls
            //zoom to america
            usCenterUI.addEventListener('click', function () {
                map.setCenter(unitedstates);
                map.setZoom(5);
            });

            //HOUSTON BUTTON-----------------------------------------
            // Set CSS for the control border
            var houCenterUI = document.createElement('div');
            houCenterUI.id = 'UI';
            houCenterUI.title = 'Click to recenter to Houston';
            controlDiv.appendChild(houCenterUI);

            // Set CSS for the control interior
            var houCenterText = document.createElement('div');
            houCenterText.id = 'UIText';
            houCenterText.innerHTML = 'Houston';
            houCenterUI.appendChild(houCenterText);

            // Set up the click event listener for controls
            //zoom to houston area
            houCenterUI.addEventListener('click', function () {
                map.setCenter(houston);
                map.setZoom(10);
            });

            //WOODLANDS BUTTON---------------------------------------
            // Set CSS for the control border
            var wdlndsCenterUI = document.createElement('div');
            wdlndsCenterUI.id = 'UI';
            wdlndsCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(wdlndsCenterUI);

            // Set CSS for the control interior
            var wdlndsCenterText = document.createElement('div');
            wdlndsCenterText.id = 'UIText';
            wdlndsCenterText.innerHTML = 'Woodlands';
            wdlndsCenterUI.appendChild(wdlndsCenterText);

            //zoom to woodlands area
            wdlndsCenterUI.addEventListener('click', function () {
                map.setCenter(woodlands);
                map.setZoom(12);
            });

            //AUSTIN BUTTON------------------------------------------
            // Set CSS for the control border
            var ausCenterUI = document.createElement('div');
            ausCenterUI.id = 'UI';
            ausCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(ausCenterUI);

            // Set CSS for the control interior
            var ausCenterText = document.createElement('div');
            ausCenterText.id = 'UIText';
            ausCenterText.innerHTML = 'Austin';
            ausCenterUI.appendChild(ausCenterText);

            //zoom to austin area
            ausCenterUI.addEventListener('click', function () {
                map.setCenter(austin);
                map.setZoom(10);
            });

            //MIDLAND BUTTON----------------------------------------
            // Set CSS for the control border
            var mdlndCenterUI = document.createElement('div');
            mdlndCenterUI.id = 'UI';
            mdlndCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(mdlndCenterUI);

            // Set CSS for the control interior
            var mdlndCenterText = document.createElement('div');
            mdlndCenterText.id = 'UIText';
            mdlndCenterText.innerHTML = 'Midland';
            mdlndCenterUI.appendChild(mdlndCenterText);

            //zoom to midland area
            mdlndCenterUI.addEventListener('click', function () {
                map.setCenter(midland);
                map.setZoom(12);
            });

            //CENTER BUTTON-----------------------------------------
            // Set CSS for the control border
            var goCenterUI = document.createElement('div');
            goCenterUI.id = 'CenterUI';
            goCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(goCenterUI);

            // Set CSS for the control interior
            var goCenterText = document.createElement('div');
            goCenterText.id = 'UIText';
            goCenterText.innerHTML = 'Center Map';
            goCenterUI.appendChild(goCenterText);

            // Set up the click event listener for controls
            //Center Button will center the map to show all markers on the map
            goCenterUI.addEventListener('click', function () {
                var bounds = new google.maps.LatLngBounds();
                for (var k = 0; k < array.length; k++) {
                    bounds.extend(array[k].getPosition());
                }
                map.fitBounds(bounds);
            });

            //DALLAS BUTTON----------------------------------------
            // Set CSS for the control border
            var dalCenterUI = document.createElement('div');
            dalCenterUI.id = 'UI';
            dalCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(dalCenterUI);

            // Set CSS for the control interior
            var dalCenterText = document.createElement('div');
            dalCenterText.id = 'UIText';
            dalCenterText.innerHTML = 'Dallas';
            dalCenterUI.appendChild(dalCenterText);

            //zoom to dallas area
            dalCenterUI.addEventListener('click', function () {
                map.setCenter(dallas);
                map.setZoom(10);
            });

            //MILWAUKEE BUTTON----------------------------------------
            // Set CSS for the control border
            var mlwkeeCenterUI = document.createElement('div');
            mlwkeeCenterUI.id = 'UI';
            mlwkeeCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(mlwkeeCenterUI);

            // Set CSS for the control interior
            var mlwkeeCenterText = document.createElement('div');
            mlwkeeCenterText.id = 'UIText';
            mlwkeeCenterText.innerHTML = 'Milwaukee';
            mlwkeeCenterUI.appendChild(mlwkeeCenterText);

            //zoom to milwaukee
            mlwkeeCenterUI.addEventListener('click', function () {
                map.setCenter(milwaukee);
                map.setZoom(12);
            });

            //EASTON BUTTON----------------------------------------------
            // Set CSS for the control border
            var estnCenterUI = document.createElement('div');
            estnCenterUI.id = 'UI';
            estnCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(estnCenterUI);

            // Set CSS for the control interior
            var estnCenterText = document.createElement('div');
            estnCenterText.id = 'UIText';
            estnCenterText.innerHTML = 'Easton';
            estnCenterUI.appendChild(estnCenterText);

            //zoom to easton area
            estnCenterUI.addEventListener('click', function () {
                map.setCenter(easton);
                map.setZoom(6);
            });

            //MIRAMAR BUTTON------------------------------------------------
            // Set CSS for the control border
            var mrmrCenterUI = document.createElement('div');
            mrmrCenterUI.id = 'UI';
            mrmrCenterUI.title = 'Click to recenter';
            controlDiv.appendChild(mrmrCenterUI);

            // Set CSS for the control interior
            var mrmrCenterText = document.createElement('div');
            mrmrCenterText.id = 'UIText';
            mrmrCenterText.innerHTML = 'Miramar';
            mrmrCenterUI.appendChild(mrmrCenterText);

            //zoom to florida
            mrmrCenterUI.addEventListener('click', function () {
                map.setCenter(miramar);
                map.setZoom(11);
            });

            //DUBAI BUTTON-----------------------------------------
            // Set CSS for the control border
            var dbaiCenterUI = document.createElement('div');
            dbaiCenterUI.id = 'UI';
            dbaiCenterUI.title = 'Click to recenter to Dubai';
            controlDiv.appendChild(dbaiCenterUI);

            // Set CSS for the control interior
            var dbaiCenterText = document.createElement('div');
            dbaiCenterText.id = 'UIText';
            dbaiCenterText.innerHTML = 'Dubai';
            dbaiCenterUI.appendChild(dbaiCenterText);

            // Set up the click event listener for controls
            //zoom to america
            dbaiCenterUI.addEventListener('click', function () {
                map.setCenter(dubai);
                map.setZoom(10);
            });
        }

        /**
         * Define a property to hold the center state.
         * @private
         */
        CenterControl.prototype.center_ = null;
        /**
         * Gets the map center.
         * @return {?google.maps.LatLng}
         */
        CenterControl.prototype.getCenter = function () {
            return this.center_;
        };
        /**
         * Sets the map center.
         * @param {?google.maps.LatLng} center
         */
        CenterControl.prototype.setCenter = function (center) {
            this.center_ = center;
        };

        //Settings for InfoWindow 
        function bindInfoWindow(marker, map, infoWindow, html) {
            google.maps.event.addListener(marker, 'click', function () {
                infoWindow.setContent(html);
                infoWindow.open(map, marker);
            });
        }

        //Function to retrieve data from XML (may not need it)
        //function downloadUrl(url, callback) {
        //    var request = window.ActiveXObject ?
        //            new ActiveXObject('Microsoft.XMLHTTP') :
        //            new XMLHttpRequest;
        //    request.onreadystatechange = function () {
        //        if (request.readyState === 4) {
        //            request.onreadystatechange = doNothing;
        //            callback(request, request.status);
        //        }
        //    };
        //    request.open('GET', url, true);
        //    request.send(null);
        //}

        function doNothing() {
        }

    </script>

    <h1 style="text-align: center;">CLIENT VISIT MAP</h1>

    <%--<table style="width: 100%; height: 100%; align-items: center;">--%>
    <div class="container">
        <%--<div id="map" style="width: 1200px; border: solid; border-width: 2px; border-color: black; margin: 2px 50px 5px 50px;">--%>



        <%--<table style="width: 1150px; align-content: center; margin: 0 50px 15px 50px; padding: 0 45px 0 45px;">--%>
        <table class="table">
            <tr>
                <td style="width: 100%;">
                    <div id="map_container">
                        <div id="map"></div>
                    </div>
                </td>
                <td style="padding-left: 35px;">
                    <b>Select Client</b>
                    <br />
                    <asp:ListBox Style="width: 300px; height: 450px; padding: 0 15px 0 15px;" ID="clientListBox" onClick="centerClient();" runat="server"></asp:ListBox>
                </td>


            </tr>
        </table>
    </div>
</asp:Content>
