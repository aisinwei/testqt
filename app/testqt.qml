/*
 * Copyright (C) 2016 The Qt Company Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtWebSockets 1.0
import QtLocation 5.9
import QtPositioning 5.6

ApplicationWindow {
	id: root
	visible: true
	width: 1080
	height: 1488
	title: qsTr("TestQt")
	
	Map{
		id: map
		property variant markers
		property variant mapItems
		property int markerCounter: 0 // counter for total amount of markers. Resets to 0 when number of markers = 0
		property int currentMarker
		property int lastX : -1
		property int lastY : -1
		property int pressX : -1
		property int pressY : -1
		property int jitterThreshold : 30
		width: 1080
		height: 1488
		plugin: Plugin {
			name: "mapbox"
			PluginParameter { name: "mapbox.access_token";
			value: "pk.eyJ1IjoiYWlzaW53ZWkiLCJhIjoiY2pqNWg2cG81MGJoazNxcWhldGZzaDEwYyJ9.imkG45PQUKpgJdhO2OeADQ" }
		}
		center: QtPositioning.coordinate(59.9485, 10.7686)	// The Qt Company in Oslo
		zoomLevel: 14
		
	//	GeocodeModel {
	//		id: geocodeModel
	//		plugin: map.plugin
	//		onStatusChanged: {
	//			if ((status == GeocodeModel.Ready) || (status == GeocodeModel.Error))
	//				map.geocodeFinished()
	//		}
	//		onLocationsChanged:
	//		{
	//			if (count == 1) {
	//				map.center.latitude = get(0).coordinate.latitude
	//				map.center.longitude = get(0).coordinate.longitude
	//			}
	//		}
	//	}
	//	MapItemView {
	//		model: geocodeModel
	//		delegate: pointDelegate
	//	}
	//	Component {
	//		id: pointDelegate
	//		MapCircle {
	//			id: point
	//			radius: 1000
	//			color: "#46a2da"
	//			border.color: "#190a33"
	//			border.width: 2
	//			smooth: true
	//			opacity: 0.25
	//			center: locationData.coordinate
	//		}
	//	}
	//	function geocode(fromAddress)
	//	{
	//		// send the geocode request
	//		geocodeModel.query = fromAddress
	//		geocodeModel.update()
	//	}
		
		MapQuickItem {
			id: poiTheQtComapny
			sourceItem: Rectangle { width: 14; height: 14; color: "#e41e25"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
			coordinate {
				latitude: 59.9485
				longitude: 10.7686
			}
			opacity: 1.0
			anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
		}
		
		MapQuickItem {
			sourceItem: Text{
				text: "The Qt Company"
				color:"#242424"
				font.bold: true
				styleColor: "#ECECEC"
				style: Text.Outline
			}
			coordinate: poiTheQtComapny.coordinate
			anchorPoint: Qt.point(-poiTheQtComapny.sourceItem.width * 0.5,poiTheQtComapny.sourceItem.height * 1.5)
		}
		
		RouteModel {
			id: routeModel
			plugin : map.plugin
			query:  RouteQuery {
				id: routeQuery
			}
			onStatusChanged: {
				if (status == RouteModel.Ready) {
					switch (count) {
					case 0:
						// technically not an error
						map.routeError()
						break
					case 1:
					//	map.showRouteList()
						break
					}
				} else if (status == RouteModel.Error) {
					map.routeError()
				}
			}
		}
		
		Component {
			id: routeDelegate

			MapRoute {
				id: route
				route: routeData
				line.color: "#46a2da"
				line.width: 10
				smooth: true
				opacity: 0.8
			}
		}
		
		MapItemView {
			model: routeModel
			delegate: routeDelegate
			autoFitViewport: true
		}
		function calculateCoordinateRoute(startCoordinate, endCoordinate)
		{
			console.log("calculateCoordinateRoute")
			// clear away any old data in the query
			routeQuery.clearWaypoints();
			// add the start and end coords as waypoints on the route
			routeQuery.addWaypoint(startCoordinate)
			routeQuery.addWaypoint(endCoordinate)
			routeQuery.travelModes = RouteQuery.CarTravel
			routeQuery.routeOptimizations = RouteQuery.FastestRoute
			for (var i=0; i<9; i++) {
				routeQuery.setFeatureWeight(i, 0)
			}
			routeModel.update();
			// center the map on the start coord
		//	map.center = startCoordinate;
		}
		
		function calculateMarkerRoute()
		{
			var startCoordinate = QtPositioning.coordinate(59.9485, 10.7686)	// The Qt Company in Oslo
			
			console.log("calculateMarkerRoute")
			routeQuery.clearWaypoints();
			routeQuery.addWaypoint(startCoordinate)
			routeQuery.addWaypoint(mouseArea.lastCoordinate)
			routeQuery.travelModes = RouteQuery.CarTravel
			routeQuery.routeOptimizations = RouteQuery.FastestRoute
			for (var i=0; i<9; i++) {
				routeQuery.setFeatureWeight(i, 0)
			}
			routeModel.update();
		//	map.center = startCoordinate;
		}
		MouseArea {
			id: mouseArea
			property variant lastCoordinate
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			
			onPressed : {
				map.lastX = mouse.x
				map.lastY = mouse.y
				map.pressX = mouse.x
				map.pressY = mouse.y
				lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
			}
			
			onPositionChanged: {
				if (mouse.button == Qt.LeftButton) {
					map.lastX = mouse.x
					map.lastY = mouse.y
				}
			}
			
			onPressAndHold:{
				if (Math.abs(map.pressX - mouse.x ) < map.jitterThreshold
						&& Math.abs(map.pressY - mouse.y ) < map.jitterThreshold) {
					map.calculateMarkerRoute();
				}
			}
		}
		
	}
	
	Item {
		id: btn_present_position
		x: 942
		y: 1328
		
		Button {
			id: btn_present_position_
			width: 100
			height: 100
		
			property variant fromCoordinate: QtPositioning.coordinate(59.9483, 10.7695)
			property variant toCoordinate: QtPositioning.coordinate(59.9645, 10.671)
		
			Address {
				id :fromAddress
				street: "Sandakerveien 116"
				city: "Oslo"
				country: "Norway"
				state : ""
				postalCode: "0484"
			}

			Address {
				id: toAddress
				street: "Holmenkollveien 140"
				city: "Oslo"
				country: "Norway"
				postalCode: "0791"
			}
			
			function doSomething() {
			//	map.geocode(fromAddress);
				map.calculateCoordinateRoute(fromCoordinate, toCoordinate);
			}

			onClicked: { doSomething() }

			Image {
				id: image
				width: 92
				height: 92
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				source: "images/thum500_t002_0_ip_0175.jpg"
			}
		}
	}
	
	BtnMapDirection {
		id: btn_map_direction
		x: 15
		y: 20
	}

	BtnArrow {
		id: btn_arrow
		x: 940
		y: 20
	}

	BtnShrink {
		id: btn_shrink
		x: 23
		y:1200
	}

	BtnEnlarge {
		id: btn_enlarge
		x: 23
		y: 1330
	}

	ImgDestinationDirection {
		id: img_destination_direction
		x: 120
		y: 20
	}

	ProgressNextCross {
		id: progress_next_cross
		x: 225
		y: 20
	}
}
