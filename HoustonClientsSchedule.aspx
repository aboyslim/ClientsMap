<%@ Page Title="" Language="C#" MasterPageFile="~/ClientVisitMapMaster.Master" AutoEventWireup="true" CodeBehind="HoustonClientsSchedule.aspx.cs" Inherits="ClientVisitMap.HoustonClientsSchedule" %>
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
        //array to hold consultant markers
        var cnsltArrMarkers = [];

        //Only need when geocoding
        var geocoder = new google.maps.Geocoder();                  
        
        //variable with all the table data
        var houstonSchedule = JSON.parse('<%= getHoustonClients() %>');
        var cnsltMarkers = JSON.parse('<%= getCnsltRows() %>'); 
        
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

        var clientIcon, geocodeIcon, cnslticon;
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

            //CONSULTANTS---Fill map with Consultant markers by zipcode ----------------------------------------------
            
            cnslticon = new google.maps.MarkerImage('/Images/clientpin-small.png',
                               new google.maps.Size(40, 40),
                               new google.maps.Point(0, 0),
                               new google.maps.Point(19, 39)
                               );

            var jsZipsCount = "<%= zipsCount %>"; //Get row count from code behind and store into JS var

            for (var j = 0; j < jsZipsCount; j++) {

                var cnsltData = cnsltMarkers[j];//store array of consultant information
                var cnsltLatLng = new google.maps.LatLng(cnsltData.lat, cnsltData.lng);
                var cnsltName = cnsltData.name;
                var cnsltZip = cnsltData.zip;
                var cnsltSuper = cnsltData.super;
                var cnsltHtml = cnsltName + "<br />" + cnsltZip + "<br /> <b>Supervisor: </b>" + cnsltSuper; 
                var currZip;
                var nextZip;
                                
                //Create consultant marker
                var cnsltZipMarker = new google.maps.Marker({
                    map: map,
                    position: cnsltLatLng,
                    title: cnsltName,
                    id: cnsltName,
                    icon: cnslticon
                });
                              
                //Add displayed markers into array of markers
                cnsltArrMarkers.push(cnsltZipMarker);
                oms.addMarker(cnsltZipMarker);
                cnsltZipMarker.setVisible(false);

                //Attach InfoWindow to each marker with content
                bindInfoWindow(cnsltZipMarker, map, infoWindow, cnsltHtml);

            }//END for loop
            //END CONSULTANT MARKERS --------------------------------------------------------------------------------------------


            //--------------------CLIENTS--------------------------------------------------------------------                      

            var schdlCount = <%= schdlCount %>;
            
            //create icon to display green pin as marker
            clientIcon = new google.maps.MarkerImage('/Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );           

            
            geocodeIcon = new google.maps.MarkerImage('/Images/clientpin.png',
                               new google.maps.Size(40, 40),
                               new google.maps.Point(0, 0),
                               new google.maps.Point(19, 39)
                               );

            //-------------------------------------------DISPLAY MARKERS FOR TODAYSSCHEDULE DATABASE-----------------------------------------------------------------------
            for (var schdlIndx = 0; schdlIndx < schdlCount; schdlIndx++)
            {        
                var schdlData = houstonSchedule[schdlIndx];
                var schdleName = schdlData.schdlCmpName;
                var member = schdlData.schdlCmpMembId;
                var schdlAddress = houstonSchedule[schdlIndx].schdlCmpAddr1 + ", " + houstonSchedule[schdlIndx].schdlCity + ", " + houstonSchedule[schdlIndx].schdlState + " " + houstonSchedule[schdlIndx].schdlZip;
                var startStr = houstonSchedule[schdlIndx].schdlStart;
                var endStr = houstonSchedule[schdlIndx].schdlEnd;
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
                         + "<a target='_blank' href='https://cw.ergos.com/v4_6_release/services/system_io/Service/fv_sr100_request.rails?service_recid=" + serviceID + "&companyName=ERGOS'>" + serviceID + "</a>" + "<br />" 
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

            var toggleControlDiv = document.createElement('div');
            var toggleControl = new ToggleControl(toggleControlDiv, map,  new google.maps.LatLng(38.226402, -89.666464));
            toggleControlDiv.index = 2;
            toggleControlDiv.style['padding-bottom'] = '3px';
            map.controls[google.maps.ControlPosition.BOTTOM_CENTER].push(toggleControlDiv);
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
                        if (clientList.options[i].value == houstonSchedule[j].schdlCmpName + " - " + houstonSchedule[j].schdlServiceId)
                        {
                            var point = new google.maps.LatLng(houstonSchedule[j].llLat, houstonSchedule[j].llLng);
                            map.setCenter(point);
                            if (map.getZoom() < 16){map.setZoom(18);}
                            infoWindow.setContent("<b>" + houstonSchedule[j].schdlCmpName + "</b> <br />Click pin for details.");
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
            var houston = new google.maps.LatLng(29.76328, -95.36327)

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
        }

        function ToggleControl(ctrlDiv, map, center){

            // We set up a variable for this since we're adding event listeners later.
            var control = this;

            // Set the center property upon construction
            control.center_ = center;
            ctrlDiv.style.clear = 'both';

            //SHOW/CLEAR CONSULTANTS BUTTON-----------------------------------------
            // Set CSS for the control border
            var showCnsltntsUI = document.createElement('div');
            showCnsltntsUI.id = 'UI';
            showCnsltntsUI.title = '';
            ctrlDiv.appendChild(showCnsltntsUI);

            // Set CSS for the control interior
            var showCnsltntsText = document.createElement('div');
            showCnsltntsText.id = 'UIText';
            showCnsltntsText.innerHTML = 'Show Consultants';
            showCnsltntsUI.appendChild(showCnsltntsText);

            // Set up the click event listener for controls            
            showCnsltntsUI.addEventListener('click', function () {         
                if (showCnsltntsText.innerHTML == 'Hide Consultants')
                {
                    for(var mrkr = 0; mrkr < cnsltArrMarkers.length; mrkr++){
                        cnsltArrMarkers[mrkr].setVisible(false);
                    }
                    showCnsltntsText.innerHTML = 'Show Consultants';
                
                }else if (showCnsltntsText.innerHTML == 'Show Consultants')
                {               
                    for(var mrkr = 0; mrkr < cnsltArrMarkers.length; mrkr++){
                        cnsltArrMarkers[mrkr].setVisible(true);
                    }
                    showCnsltntsText.innerHTML = 'Hide Consultants';                
                }
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

    <h1 style="text-align: center;margin-bottom: 0;font-size: 36px;">CLIENT VISIT MAP</h1>
    <h2 style="text-align: center;margin-bottom: 0;">HOUSTON CLIENTS</h2>

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
                <td class="btmdiv" style="padding-left: 15px;">

                    <div>
                    <asp:Button CssClass ="btnStyle" id="clientsBtn" Text="Active Clients" runat="server" OnClick="clientsBtn_Click" />
                    </div>

                    <b>Select Client</b>
                    <br />
                    <div id="listBoxDiv" style="overflow: auto; width: 275px; height: 450px;"">
                        <asp:ListBox ID="clientListBox" onClick="centerClient();" runat="server"></asp:ListBox>
                    </div>

                    <table class="regionbtns" style="padding-top: 16px;">
                        <tr>
                            <td>
                                <input disabled="disabled" type="button" onclick="document.location.href = 'HoustonClientsSchedule.aspx'" value="Houston"/>
                
                                <input type="button" id="corpBtn" onclick="document.location.href = 'CorporateClientsSchedule.aspx'" value="Corporate" />
                            
                                <input type="button" id="dalBtn" onclick="document.location.href = 'DallasClientsSchedule.aspx'" value="Dallas" />
                            </td>
                        </tr>

                        <tr>
                            <td>                               
                                <input type="button" id="dubBtn" onclick="document.location.href = 'DubaiClientsSchedule.aspx'" value="Dubai" />

                                 <input type="button" id="ausBtn" onclick="document.location.href = 'AustinClientsSchedule.aspx'" value="Austin" />

                                <input type="button" id="sanBtn" onclick="document.location.href = 'SanAntonioClientsSchedule.aspx'" value="San Antonio" />
                            </td>
                        </tr>

                        <tr>
                            <td>        
                                <input type="button" id="wdlndsBtn" onclick="document.location.href = 'WoodlandsClientsSchedule.aspx'" value="Woodlands" />
                                 
                                <input type="button" id="mdlndBtn" onclick="document.location.href = 'MidlandClientsSchedule.aspx'" value="Midland" />
                                                    
                               <input type="button" id="njBtn" onclick="document.location.href = 'NewJerseyClientsSchedule.aspx'" value="New Jersey" />
                           </td>
                        </tr>

                        <tr>
                            <td>
                                <input type="button" id="nyBtn"  onclick="document.location.href = 'NewYorkClientsSchedule.aspx'" value="New York" />

                                <input type="button" id="neBtn"  onclick="document.location.href = 'NorthEastClientsSchedule.aspx'" value="North East" />

                                <input type="button" id="aioBtn"  onclick="document.location.href = 'AIOClientsSchedule.aspx'" value="AIO" />
                            </td>
                        </tr>     
                        
                         <tr>
                            <td>
                                <input type="button" id="allBtn" value="View All" onclick="document.location.href = '/TodaysSchedule.aspx'"/>
                            </td>
                        </tr>      
                    </table>
                </td>
            </tr>
        </table>
    </div>


</asp:Content>
