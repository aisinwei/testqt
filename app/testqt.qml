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
		property variant pathcounter : 0
		property variant segmentcounter : 0
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
		center: QtPositioning.coordinate(36.131516, -115.151507)	// Las Vegas Convention Center
		zoomLevel: 14
		property variant modepositionfollowing : false 
		property variant currentpostion : QtPositioning.coordinate(36.131516, -115.151507)	// Las Vegas Convention Center
		
		MapQuickItem {
			id: poi
			sourceItem: Rectangle { width: 14; height: 14; color: "#e41e25"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
			coordinate {
				latitude: 36.131516
				longitude: -115.151507
			}
			opacity: 1.0
			anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
		}
		MapQuickItem {
			sourceItem: Text{
				text: "Convention Center"
				color:"#242424"
				font.bold: true
				styleColor: "#ECECEC"
				style: Text.Outline
			}
			coordinate: poi.coordinate
			anchorPoint: Qt.point(-poi.sourceItem.width * 0.5, poi.sourceItem.height * 1.5)
		}
		MapQuickItem {
			id: marker
			anchorPoint.x: imageMarker.width/2
			anchorPoint.y: imageMarker.height/2
			sourceItem: Image {
				id: imageMarker
				width: 150
				height: 150
				source: "images/car_icon.svg"
			}
			coordinate: map.currentpostion
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
						console.log("No route found")
						break
					case 1:
						map.pathcounter = 0
						map.segmentcounter = 0
						// report position on route and 1st instruction
						console.log("1 route found")
						console.log("path: ", get(0).path.length, "segment: ", get(0).segments.length, "distance: ", get(0).segments.distance)
						for(var i = 0; i < get(0).path.length; i++){
						//	console.log("", get(0).path[i])
						}
						console.log("1st instruction: ", get(0).segments[map.segmentcounter].maneuver.instructionText)
						console.log("direction: ", get(0).segments[map.segmentcounter].maneuver.direction)
						console.log("distanceToNextInstruction: ", get(0).segments[map.segmentcounter].maneuver.distanceToNextInstruction)
						break
					}
				} else if (status == RouteModel.Error) {
					console.log("route status error")
				}
			}
		}
		
		Component {
			id: routeDelegate

			MapRoute {
				id: route
				route: routeData
				line.color: "#4658da"
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
		
		function calculateMarkerRoute()
		{
			var startCoordinate = QtPositioning.coordinate(36.131516, -115.151507)	// Las Vegas Convention Center
			
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
					map.modepositionfollowing = false
				//	arrow.positionTimer.stop();
					map.calculateMarkerRoute();
				}
			}
		}
		gesture.onFlickStarted: {
			map.modepositionfollowing = false
		}
		gesture.onPanStarted: {
			map.modepositionfollowing = false
		}
		
		function updatePositon()
		{
			console.log("updatePositon")
			if(routeModel.status == RouteModel.Ready){
				if(pathcounter < routeModel.get(0).path.length){
				//	console.log("path: ", pathcounter, "/", routeModel.get(0).path.length, "", routeModel.get(0).path[pathcounter])
					map.currentpostion = routeModel.get(0).path[pathcounter]
					marker.coordinate = map.currentpostion
					if(map.modepositionfollowing == true){
						map.center = map.currentpostion
					}
					// report a new instruction if current position matches with the head position of the segment
					if(segmentcounter < routeModel.get(0).segments.length){
						if(routeModel.get(0).path[pathcounter] == routeModel.get(0).segments[segmentcounter].path[0]){
							console.log("new segment: ", segmentcounter, "/", routeModel.get(0).segments.length)
							console.log("instruction: ", routeModel.get(0).segments[segmentcounter].maneuver.instructionText)
							console.log("direction: ", routeModel.get(0).segments[map.segmentcounter].maneuver.direction)
							console.log("distanceToNextInstruction: ", routeModel.get(0).segments[map.segmentcounter].maneuver.distanceToNextInstruction)
							segmentcounter++
						}
					}
					pathcounter++
				}else{
					pathcounter = 0
					segmentcounter = 0
					map.currentpostion = QtPositioning.coordinate(36.131516, -115.151507)	// Las Vegas Convention Center
					marker.coordinate = map.currentpostion
					if(map.modepositionfollowing == true){
						map.center = map.currentpostion
					}
				}
			}else{
				pathcounter = 0
				segmentcounter = 0
			}
		}
	}
	
	// use external nmea data to simulate current position
//	PositionSource {
//		id: src
//		updateInterval: 500
//		active: true
//		nmeaSource: "images/nmea.txt"
//		
//		onPositionChanged: {
//			var coord = src.position.coordinate;
//			console.log("Coordinate: ", src.position.coordinate);
//			map.currentpostion = src.position.coordinate;
//		}
//	}
	
	Item {
		id: present_position
		x: 942
		y: 1328
		
		Button {
			id: btn_present_position
			width: 100
			height: 100
			
			function present_position_clicked() {
				map.modepositionfollowing = true
				map.center = map.currentpostion
			}
			onClicked: { present_position_clicked() }
			
			Image {
				id: image_present_position
				width: 92
				height: 92
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				source: "images/thum500_t002_0_ip_0175.jpg"
			}
		}
	}
	Item {
		id: arrow
		x: 940
		y: 20
		
		Timer {
			id: positionTimer
			interval: 250; running: false; repeat: true
			onTriggered: map.updatePositon()
		}
		
		Button {
			id: btn_arrow
			width: 100
			height: 100
			
			function arrow_clicked() {
				if(positionTimer.running == false){
					map.modepositionfollowing = true
					positionTimer.start();
				}else{
					map.modepositionfollowing = false
					positionTimer.stop();
				}
			}
			
			onClicked: { arrow_clicked() }
			
			Image {
				id: image_arrow
				width: 92
				height: 92
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				source: "images/SW_Patern_1.bmp"
			}
		}
	}
	
	BtnMapDirection {
		id: btn_map_direction
		x: 15
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
