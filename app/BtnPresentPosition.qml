import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
	Button {
		id: btn_present_position
		width: 100
		height: 100

		function doSomething() {
			// ...
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
