import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
	Button {
		id: btn_arrow
		width: 100
		height: 100

		function settleState() {
			if(btn_arrow.state == "1"){
				btn_arrow.state = "2";
			} else if(btn_arrow.state == "2"){
				btn_arrow.state = "3";
			} else {
				btn_arrow.state = "1";
			}
		}

		onClicked: { settleState() }

		Image {
			id: image
			width: 92
			height: 92
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			source: "images/SW_Patern_1.bmp"
		}

		states: [
			State {
				name: "1"
				PropertyChanges { target: image; source: "images/SW_Patern_1.bmp" }
			},
			State {
				name: "2"
				PropertyChanges { target: image; source: "images/SW_Patern_2.bmp" }
			},
			State {
				name: "3"
				PropertyChanges { target: image; source: "images/SW_Patern_3.bmp" }
			}
		]

	}
}
