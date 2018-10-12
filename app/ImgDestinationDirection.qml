import QtQuick 2.0

Item {
	id: img_destination_direction

	width: childrenRect.width
	height: childrenRect.height

	function settleState() {
		if(img_destination_direction.state == "1"){
			img_destination_direction.state = "2";
		} else if(img_destination_direction.state == "2"){
			img_destination_direction.state = "3";
		} else if(img_destination_direction.state == "3"){
			img_destination_direction.state = "4";
		} else if(img_destination_direction.state == "4"){
			img_destination_direction.state = "5";
		} else if(img_destination_direction.state == "5"){
			img_destination_direction.state = "6";
		} else if(img_destination_direction.state == "6"){
			img_destination_direction.state = "7";
		} else if(img_destination_direction.state == "7"){
			img_destination_direction.state = "8";
		} else if(img_destination_direction.state == "8"){
			img_destination_direction.state = "9";
		} else {
			img_destination_direction.state = "1";
		}
	}

	Image {
		id: direction
		x: 0
		y: 0
		width: 100
		height: 100
		source: "images/1_uturn.png"

		MouseArea {
			anchors.fill: parent
			onClicked: { settleState() }
		}
	}

	states: [
		State {
			name: "1"
			PropertyChanges { target: direction; source: "images/1_uturn.png" }
		},
		State {
			name: "2"
			PropertyChanges { target: direction; source: "images/2_sharp_right.png" }
		},
		State {
			name: "3"
			PropertyChanges { target: direction; source: "images/3_right.png" }
		},
		State {
			name: "4"
			PropertyChanges { target: direction; source: "images/4_slight_right.png" }
		},
		State {
			name: "5"
			PropertyChanges { target: direction; source: "images/5_straight.png" }
		},
		State {
			name: "6"
			PropertyChanges { target: direction; source: "images/6_slight_left.png" }
		},
		State {
			name: "7"
			PropertyChanges { target: direction; source: "images/7_left.png" }
		},
		State {
			name: "8"
			PropertyChanges { target: direction; source: "images/8_sharp_left.png" }
		},
		State {
			name: "9"
			PropertyChanges { target: direction; source: "images/Dest_Flag.jpg" }
		}
	]
}
