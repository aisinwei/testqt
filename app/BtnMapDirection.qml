import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
	Button {
		id: btn_map_direction
		width: 100
		height: 100

		function settleState() {
			if(btn_map_direction.state == "HeadingUp"){
				btn_map_direction.state = "NorthUp";
			} else {
				btn_map_direction.state = "HeadingUp";
			}
		}

		onClicked: { settleState() }

		Image {
			id: image
			width: 92
			height: 92
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			source: "images/Direction_Hup.jpeg"
		}

		states: [
			State {
				name: "HeadingUp"
				PropertyChanges { target: image; source: "images/Direction_Hup.jpeg" }
			},
			State {
				name: "NorthUp"
				PropertyChanges { target: image; source: "images/Direction_Nup.jpeg" }
			}
		]
	}
}
