<%@ Page Title="" Language="C#" MasterPageFile="~/ClientVisitMapMaster.Master" AutoEventWireup="true" CodeBehind="UpdateAddresses-local.aspx.cs" Inherits="ClientVisitMap.UpdateAddresses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <script type="text/javascript">

        var map; //map variable used throughout the project
        var infoWindow; //infoWindow variable  

        //Rand range for spacing out multiple markers on the same spot (if used)
        //var min = .9997379, max = 1.000001;

        //var markerCluster; //MarkerClusterer object (if used)

        var cnsltArrMarkers = [];//array to hold consultant markers
        var clientArrMarkers = [];//array to hold client markers        

        //Only need when geocoding
        var geocoder = new google.maps.Geocoder();

        <%--var clientGeocodes = JSON.parse('<%= getClientAddresses() %>');
        var clientGeocodesTwo = JSON.parse('<%= getClientAddressesCopy() %>');
        var clientMarkers = JSON.parse('<%= getClientLatLngs() %>');
        var clientLatLngs = JSON.parse('<%= getClientLatLngs() %>');--%>
        var oldAddresses = JSON.parse('<%= getOldAddresses() %>');

        //Default Map Settings
        var zoom = 4;
        var center = new google.maps.LatLng(37.429142, -85.529980); //Static center of where all markers can be shown
        var cnsltMapOptions = {//Settings for map
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

        var clientIcon;
        var geocodedClientIcon;
        var nextAddress = 0;
        var delay = 100;

        geocodedClientIcon = new google.maps.MarkerImage('Images/clientpin.png',
                           new google.maps.Size(40, 40),
                           new google.maps.Point(0, 0),
                           new google.maps.Point(19, 39)
                           );

        //Main function that loads the map, controls and settings
        function load() {

            //Create map
            map = new google.maps.Map(document.getElementById("map"), cnsltMapOptions); //End Map Variable

            infoWindow = new google.maps.InfoWindow; //InfoWindow object

            //Closes current InfoWidnow when clicked on map
            google.maps.event.addListener(map, "click", function () {
                infoWindow.close();
            });

            //--------------------CLIENTS--------------------------------------------------------------------                      

            //create icon to display green pin as marker
            clientIcon = new google.maps.MarkerImage('Images/clientpin-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );

            //UPDATE ADDRESS AND LAT/LNG AS WELL AS GEOCODE AND DISPLAY MARKERS--------------------------------------------------------------------------------------------------------------------------------------------------------------
            var oldAddress = oldAddresses[nextAddress].cpycmpAddr;
            var oldAddressRecId = oldAddresses[nextAddress].cpycmpAddrRecId;
            var newAddress = oldAddresses[nextAddress].cmpAddr;
            var newAddressRecId = oldAddresses[nextAddress].cmpAddrRecId;
            var newAddressClient = oldAddresses[nextAddress].cmpName;
            var llAddressRecId = oldAddresses[nextAddress].llcmpAddrRecId;

            clHtml = "<b>" + newAddressClient + "</b> <br />" + newAddress + "<br /> " + "<br />" + oldAddressRecId; //html to display in infoWindow

            //calls SQL proc to update addresses in database
            PageMethods.updateAddress();

            // set the database values of Lat and Lng to null
            //PageMethods.setToNull(llAddressRecId);

            //geocodes new address and saves new lat/lng; goes through Geocodesingle once then uses GeocodeAddresses function
            geocodeSingle(newAddress, nextAddress, newAddressRecId, clHtml, newAddressClient, theNext); 
          
            //call GeocodeAddresses function 
            //theNext();                  

            //END UPDATE ADDRESS AND LAT/LNG AS WELL AS GEOCODE AND DISPLAY MARKERS--------------------------------------------------------------------------------------------------------------------------------------------------------------

            //--------------------END CLIENTS--------------------------------------------------------------------


            // Create the DIV to hold the control and call the CenterControl() constructor
            // passing in this DIV.
            var centerControlDiv = document.createElement('div');
            var centerControl = new CenterControl(clientArrMarkers, centerControlDiv, map, new google.maps.LatLng(38.226402, -89.666464));
            centerControlDiv.index = 1;
            centerControlDiv.style['padding-top'] = '10px';
            map.controls[google.maps.ControlPosition.TOP_CENTER].push(centerControlDiv);

            var toggleControlDiv = document.createElement('div');
            var toggleControl = new ToggleControl(toggleControlDiv, map, new google.maps.LatLng(38.226402, -89.666464));
            toggleControlDiv.index = 2;
            toggleControlDiv.style['padding-bottom'] = '3px';
            map.controls[google.maps.ControlPosition.BOTTOM_CENTER].push(toggleControlDiv);


            <%--chkList = document.getElementById('<%=CnsltntList.ClientID%>');
            checkbox = chkList.getElementsByTagName('input');
            for(var i = 0; i< checkbox.length; i++)
            {
                checkbox[i].checked = true;
                
            }    --%>

            //Resize Function
            google.maps.event.addDomListener(window, "resize", function () {
                var center = map.getCenter();
                google.maps.event.trigger(map, "resize");
                map.setCenter(center);
            });

            google.maps.event.addDomListener(window, 'load', load);

        }//END LOAD-------------------------------------------------------------------------------------

        //---GEOCODE ONLY AND EACH ADDRESS PASSED---------------------------------------------------------
        function geocodeSingle(address, index, id, iwHtml, clName, next) {

            geocoder.geocode({ address: address }, function (results, status) {
                if (status === google.maps.GeocoderStatus.OK) {
                    var llLat = results[0].geometry.location.lat();
                    var llLng = results[0].geometry.location.lng();

                    createGeocodeMarker(llLat, llLng, clName, geocodedClientIcon, iwHtml);

                    //store these in c# and processor
                    PageMethods.saveCoords(oldAddresses[index].cpycmpAddrRecId, llLat, llLng);
                } else {
                    if (status === google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                        nextAddress--;
                        delay++;
                    }
                }
                nextAddress++;
                next();
            });
        }//-----------------------------------------------------------------------------------------------

        //MAIN GEOOCODE FUNCTION, NOT SURE IS NEEDED FOR UPDATING ADDRESSES/LAT/LNGS
        function geocodeAdresses(clientAddr, next) {

            var client = oldAddresses[nextAddress].cmpName;
            var clientAddrId = oldAddresses[nextAddress].cmpAddrRecId;
            var lastUpdate = new Date(parseInt(oldAddresses[nextAddress].lastUpdated.substr(6)));
            var clHtml = client + "<br />" + clientAddr + "<br />" + lastUpdate + "<br />" + clientAddrId;

            geocoder.geocode({ address: clientAddr }, function (results, status) {
                if (status === google.maps.GeocoderStatus.OK) {
                    var lat = results[0].geometry.location.lat();
                    var lng = results[0].geometry.location.lng();

                    createGeocodeMarker(lat, lng, client, geocodedClientIcon, clHtml);

                    //store these in c# and processor
                    PageMethods.saveCoords(oldAddresses[nextAddress].cmpAddrRecId, lat, lng);
                    //}                  
                } else {
                    if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                        nextAddress--;
                        delay++;
                    }
                }
                nextAddress++;
                next();
            });
        }

        //------------------------------------------------------------------------------------------------------------------------------------
        function theNext() {
            if (nextAddress < 500) {
                //alert(clientGeocodes[nextAddress].cmpAddrs);
                setTimeout('geocodeAdresses("' + oldAddresses[nextAddress].cmpAddr + '", theNext)', delay);
                //nextAddress++
            }
        }//------------------------------------------------------------------------------------------------------------------------------------

        //-----CREATE MARKER-------------------------------------------------------------------------------------------------------------------
        function createGeocodeMarker(lat, lng, titleStr, cstmIcon, html) {

            var gcMarker = new google.maps.Marker({
                map: map,
                position: new google.maps.LatLng(lat, lng),
                icon: cstmIcon,
                title: titleStr
            });

            bindInfoWindow(gcMarker, map, infoWindow, html);

            //Add displayed markers into array of markers
            clientArrMarkers.push(gcMarker);

            //Center the map to show all markers on load
            var bounds = new google.maps.LatLngBounds();
            for (var k = 0; k < clientArrMarkers.length; k++) {
                bounds.extend(clientArrMarkers[k].getPosition());
            }

            map.fitBounds(bounds); //Center the map to show all markers on load
        }//------------------------------------------------------------------------------------------------------------------------------------

       

        function ToggleControl(ctrlDiv, map, center) {

            // We set up a variable for this since we're adding event listeners later.
            var control = this;

            // Set the center property upon construction
            control.center_ = center;
            ctrlDiv.style.clear = 'both';

            //SHOW/CLEAR CLIENTS BUTTON-----------------------------------------
            // Set CSS for the control border
            var showClientsUI = document.createElement('div');
            showClientsUI.id = 'UI';
            showClientsUI.title = 'Click to recenter to US';
            ctrlDiv.appendChild(showClientsUI);

            // Set CSS for the control interior
            var showClientsText = document.createElement('div');
            showClientsText.id = 'UIText';
            showClientsText.innerHTML = 'Hide Clients';
            showClientsUI.appendChild(showClientsText);

            // Set up the click event listener for controls
            //toggle visibilty for client markers
            showClientsUI.addEventListener('click', function () {
                if (showClientsText.innerHTML == 'Hide Clients') {
                    for (var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++) {
                        clientArrMarkers[mrkr].setVisible(false);
                    }
                    showClientsText.innerHTML = 'Show Clients';
                } else if (showClientsText.innerHTML == 'Show Clients') {
                    for (var mrkr1 = 0; mrkr1 < clientArrMarkers.length; mrkr1++) {
                        clientArrMarkers[mrkr1].setVisible(true);
                    }
                    showClientsText.innerHTML = 'Hide Clients';
                }
            });

            //SHOW/CLEAR CONSULTANTS BUTTON-----------------------------------------
            // Set CSS for the control border
            var showCnsltntsUI = document.createElement('div');
            showCnsltntsUI.id = 'UI';
            showCnsltntsUI.title = '';
            ctrlDiv.appendChild(showCnsltntsUI);

            // Set CSS for the control interior
            var showCnsltntsText = document.createElement('div');
            showCnsltntsText.id = 'UIText';
            showCnsltntsText.innerHTML = 'Hide Consultants';
            showCnsltntsUI.appendChild(showCnsltntsText);

            // Set up the click event listener for controls            
            showCnsltntsUI.addEventListener('click', function () {
                if (showCnsltntsText.innerHTML == 'Hide Consultants') {
                    for (var mrkr = 0; mrkr < cnsltArrMarkers.length; mrkr++) {
                        cnsltArrMarkers[mrkr].setVisible(false);
                    }
                    showCnsltntsText.innerHTML = 'Show Consultants';

                } else if (showCnsltntsText.innerHTML == 'Show Consultants') {
                    for (var mrkr = 0; mrkr < cnsltArrMarkers.length; mrkr++) {
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
        ToggleControl.prototype.center_ = null;
        /**
         * Gets the map center.
         * @return {?google.maps.LatLng}
         */
        ToggleControl.prototype.getCenter = function () {
            return this.center_;
        };
        /**
         * Sets the map center.
         * @param {?google.maps.LatLng} center
         */
        ToggleControl.prototype.setCenter = function (center) {
            this.center_ = center;
        };

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
        <div id="map_container">
            <div id="map"></div>
        </div>
    </div>



</asp:Content>
