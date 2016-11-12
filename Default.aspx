<%@ Page Title="" Language="C#" MasterPageFile="~/ClientVisitMapMaster.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ClientVisitMap.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <script type="text/javascript">

        var map; //map variable used throughout the project
        var infoWindow; //infoWindow variable  

        //OverlappingMarkerSpiderfier
        var oms;

        //array to hold client markers
        var clientArrMarkers = [];     

        //variables to store datatables in javascript
        <%--var clientAddresses = JSON.parse('<%= getClientAddresses() %>'); --%>
        <%--var clientGeocodesTwo = JSON.parse('<%= getClientAddressesCopy() %>');--%>
        var activeClients = JSON.parse('<%= getActiveClients() %>');         
        
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
        //var button; //variable to store Show/clear All button

        var clientIcon;//marker icon for client
        var latLng;//used to store coords
        var listBoxCount;//hold count for items in listbox
        var searchBox;
        var houBtn;

        //Main function that loads the map, controls and settings
        function load() {                    
            
            //Create map
            map = new google.maps.Map(document.getElementById("map"), cnsltMapOptions); //End Map Variable

            infoWindow = new google.maps.InfoWindow; //InfoWindow object

            oms = new OverlappingMarkerSpiderfier(map);

            //Closes current InfoWidnow when clicked on map
            google.maps.event.addListener(map, "click", function () {
                infoWindow.close();
            });

            oms.addListener('spiderfy', function(markers) {
                infoWindow.close();
            });

            var input = document.getElementById('pac-input');
            searchBox = new google.maps.places.SearchBox(input);
            //map.controls[google.maps.ControlPosition.BOTTOM_LEFT].push(input);

            map.addListener('bounds_changed', function(){
                searchBox.setBounds(map.getBounds());
            });
            
            var searchMarkers = [];

            searchBox.addListener('places_changed', function(){
                var places = searchBox.getPlaces();

                if(places.length == 0){
                    return;
                }

                var bounds = new google.maps.LatLngBounds();
                places.forEach(function(place){
                    var searchIcon = {
                        url: place.icon,
                        size: new google.maps.Size(71, 71),
                        origin: new google.maps.Point(0, 0),
                        anchor: new google.maps.Point(17, 34),
                        scaledSize: new google.maps.Size(25, 25)
                    };

                    searchMarkers.push(new google.maps.Marker({
                        map: map,
                        icon: searchIcon,
                        title: place.name,
                        position: place.geometry.location
                    }));

                    if (place.geometry.viewport)
                    {
                        bounds.union(place.geometry.viewport);
                    }else {
                        bounds.extend(place.geometry.location);
                    }
                });
                map.fitBounds(bounds);
            });
        

            //--------------------CLIENTS--------------------------------------------------------------------                   

            //COUNTS
            var acCount = <%= clntsCount %>;//getActiveClients Count
            var gccount = <%= gcCount %>; //getClientAddresses Count
            var schdlCount = <%= schdlCount %>;//getTodaysSchedule Count                     
            listBoxCount = <%= addrBoxCount %>;//bindClientAddrListBox Count
            //var copycount = <%= copyCount %>;//getClientAddressesCopy Count   
            

            //create icon to display green pin as marker
            //clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
            //                new google.maps.Size(40, 40),
            //                new google.maps.Point(0, 0),
            //                new google.maps.Point(19, 39)
            //                );
            
            //----DISPLAY CLIENT MARKERS-----------------------------------------

            for (var clIndx = 0; clIndx < acCount; clIndx++) //for rows upto 250 in latlng table
            {                
                ////////////---ALL CLIENTS---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //var clData = clientAddresses[clIndx]; //store array of latlngs for addresses
                //var clAddress = clientAddresses[clIndx].cmpAddr; 
                //clHtml = "<b>" + clientAddresses[clIndx].cmpName + "</b> <br />" + clAddress + "<br /> " + clientAddresses[clIndx].cmpAddrRecId; //html to display in infoWindow

                ////////////---ACTIVE CLIENTS---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var clData = activeClients[clIndx]; //store array of latlngs for addresses
                var acAddress = activeClients[clIndx].addr1 + ", " + activeClients[clIndx].addr2 + ", " + activeClients[clIndx].city + ", " + activeClients[clIndx].stateId + " " + activeClients[clIndx].zip; 
                clHtml = "<b>" + activeClients[clIndx].cmpName + "</b> <br />" + acAddress + "<br /> " + activeClients[clIndx].cmpAddrRecId; //html to display in infoWindow

                //while the lat and lng columns are not null
                if (clData.llLat !== null && clData.llLng !== null){
                    latLng = new google.maps.LatLng(clData.llLat, clData.llLng); 
                     
                    switch (activeClients[clIndx].ownerLevel){
                        //HOUSTON-------------------------------------------------------------------------------------------
                        case 2:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break; 
                        case 47:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;                          
                        case 60:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 61:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 69:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                                      
                            //CORPORATE----------------------------------------------------------------------------------------
                        case 38:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-TEAL.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //DALLAS------------------------------------------------------------------------------------------
                        case 46:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLUE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 70:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLUE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break; 
                            //DUBAI-------------------------------------------------------------------------------------------
                        case 52:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GOLD.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //AUSTIN--------------------------------------------------------------------------------------------
                        case 55:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-ORANGE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //SAN ANTONIO--------------------------------------------------------------------------------------------
                        case 63:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-YELLOW.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //WOODLANDS--------------------------------------------------------------------------------------------
                        case 64:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-DARKGREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 67:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-DARKGREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //MIDLAND--------------------------------------------------------------------------------------------
                        case 66:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-PURPLE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NEW JERSEY--------------------------------------------------------------------------------------------
                        case 71:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 74:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 75:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NEW YORK--------------------------------------------------------------------------------------------
                        case 72:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-PINK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NORTH EAST--------------------------------------------------------------------------------------------
                        case 73:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-LIGHTPINK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //AIO--------------------------------------------------------------------------------------------
                        case 76:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLACK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                    }      

                    //Create client marker
                    var clientMarker = new google.maps.Marker({
                        map: map,
                        position: latLng,
                        title: activeClients[clIndx].cmpName,
                        //title: clientAddresses[clIndx].cmpName,
                        icon: clientIcon
                    });

                    bindInfoWindow(clientMarker, map, infoWindow, clHtml); 

                    //Add displayed markers into array of markers
                    clientArrMarkers.push(clientMarker);//Add displayed markers into array of markers      
                    oms.addMarker(clientMarker);                         

                    //Center the map to show all markers on load
                    var bounds = new google.maps.LatLngBounds();
                    for (var k = 0; k < clientArrMarkers.length; k++) {
                        bounds.extend(clientArrMarkers[k].getPosition());
                    }
                }                
            }        
            //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                
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
        

        function showRegion()
        {
            $("button").click(function(){

                switch(this.id){
                    case 'houstonBtn': 
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 2 || activeClients[mrkr].ownerLevel != 47
                                || activeClients[mrkr].ownerLevel != 60 || activeClients[mrkr].ownerLevel != 61
                                || activeClients[mrkr].ownerLevel != 69){
                                clientArrMarkers[mrkr].setVisible(false);                                
                            }            
                            if(activeClients[mrkr].ownerLevel == 2 || activeClients[mrkr].ownerLevel == 47
                                || activeClients[mrkr].ownerLevel == 60 || activeClients[mrkr].ownerLevel == 61
                                || activeClients[mrkr].ownerLevel == 69 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }      
                        }
                        break;
                    case 'corpBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 38){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 38 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'dalBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 46 || activeClients[mrkr].ownerLevel != 70){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 46 || activeClients[mrkr].ownerLevel == 70 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'dubBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 52){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 52 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'ausBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 55){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 55 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'sanBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 63){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 63 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'wdlndsBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 64 || activeClients[mrkr].ownerLevel != 67){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 64 || activeClients[mrkr].ownerLevel == 67 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'mdlndBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 66){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 66 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'njBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 71 || activeClients[mrkr].ownerLevel != 74 || activeClients[mrkr].ownerLevel != 75){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 71 || activeClients[mrkr].ownerLevel == 74 || activeClients[mrkr].ownerLevel == 75 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'nyBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 72){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 72 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'neBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 73){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 73 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'aioBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 76){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 76 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'allBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if(clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                }

            })

            //var corpBtn = document.getElementById('corpBtn');
            //corpBtn.addEventListener('click', function(){
            //    alert("works"); 
            //    return false;
            //});
        }



        //ZOOM AND CENTER TO CLIENT WHEN NAME IS SELECTED IN LISTBOX
        function centerClient(){

            var clientList = document.getElementById('<%=clientListBox.ClientID%>');

            for(var i = 0; i < clientList.length; i++)
            {                                
                if (clientList.options[i].selected)
                {                 
                    for (var j = 0; j < listBoxCount; j++)
                    {                        
                        if (clientList.options[i].value == activeClients[j].cmpName + "  --  " + activeClients[j].addr1 + " " +  activeClients[j].addr2)
                        {
                            var point = new google.maps.LatLng(activeClients[j].llLat, activeClients[j].llLng);
                            map.setCenter(point);
                            if (map.getZoom() < 16){map.setZoom(18);}
                            infoWindow.setContent("<b>" + activeClients[j].cmpName + "</b> <br />Click pin for details.");
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
                sanantonio = new google.maps.LatLng(29.441679, -98.500711),
                austin = new google.maps.LatLng(30.463839, -97.692977),
                midland = new google.maps.LatLng(32.022167, -102.115028),
                dallas = new google.maps.LatLng(32.996748, -96.770978),               
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
                map.setZoom(4);
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

            //SAN ANTONIO BUTTON-----------------------------------------
            // Set CSS for the control border
            var sanantCenterUI = document.createElement('div');
            sanantCenterUI.id = 'UI';
            sanantCenterUI.title = 'Click to recenter to San Antonio';
            controlDiv.appendChild(sanantCenterUI);

            // Set CSS for the control interior
            var sanantCenterText = document.createElement('div');
            sanantCenterText.id = 'UIText';
            sanantCenterText.innerHTML = 'San Antonio';
            sanantCenterUI.appendChild(sanantCenterText);

            // Set up the click event listener for controls
            //zoom to houston area
            sanantCenterUI.addEventListener('click', function () {
                map.setCenter(sanantonio);
                map.setZoom(8);
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
                map.setZoom(9);
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
                map.setZoom(9);
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
                map.setZoom(9);
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
                map.setZoom(8);
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

    <h1 style="text-align: center; margin-bottom: 0; font-size: 36px;">CLIENT VISIT MAP</h1>

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
                <td class="btmdiv" style="padding: 0 15px 0 15px;">

                    <div>
                        <asp:Button CssClass="btnStyle" ID="schdlButn" Text="Today's Schedule" runat="server" OnClick="schdlButn_Click" />
                    </div>
                    <br />
                    <b>Select Client</b>
                    <br />

                    <div id="listBoxDiv" style="overflow: auto; width: 275px; height: 450px;">
                        <asp:ListBox ID="clientListBox" onClick="centerClient();" runat="server"></asp:ListBox>
                    </div>

                    <table class="regionbtns" style="padding-top: 16px;">
                        <tr>
                            <td>
                                <button id="houstonBtn" onclick="showRegion();return false;">Houston</button>

                                <button class="btnStyle" id="corpBtn" onclick="showRegion();return false;">Corporate</button>

                                <button class="btnStyle" id="dalBtn" onclick="showRegion();return false;">Dallas</button>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <button class="btnStyle" id="dubBtn" onclick="showRegion();return false;">Dubai</button>

                                <button class="btnStyle" id="ausBtn" onclick="showRegion();return false;">Austin</button>

                                <button class="btnStyle" id="sanBtn" onclick="showRegion();return false;">San Antonio</button>

                            </td>
                        </tr>

                        <tr>
                            <td>
                                <button class="btnStyle" id="wdlndsBtn" onclick="showRegion();return false;">Woodlands</button>

                                <button class="btnStyle" id="mdlndBtn" onclick="showRegion();return false;">Midland</button>

                                <button class="btnStyle" id="njBtn" onclick="showRegion();return false;">New Jersey</button>      
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <button class="btnStyle" id="nyBtn" onclick="showRegion();return false;">New York</button>

                                <button class="btnStyle" id="neBtn" onclick="showRegion();return false;">North East</button>

                                <button class="btnStyle" id="aioBtn" onclick="showRegion();return false;">AIO</button>

                                <button class="btnStyle" id="allBtn" onclick="showRegion();return false;">View All</button>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>
            <tr>
                <td class="searchbar">
                    <input id="pac-input" class="controls" type="text" size="50" placeholder="Search Places" />
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
