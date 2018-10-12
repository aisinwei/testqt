import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
	id: progress_next_cross

	function move() {
		if(progress_next_cross.state == "0.1"){
			progress_next_cross.state = "0.2"
		} else if(progress_next_cross.state == "0.2"){
			progress_next_cross.state = "0.3"
		} else if(progress_next_cross.state == "0.3"){
			progress_next_cross.state = "0.4"
		} else if(progress_next_cross.state == "0.4"){
			progress_next_cross.state = "0.5"
		} else if(progress_next_cross.state == "0.5"){
			progress_next_cross.state = "0.6"
		} else if(progress_next_cross.state == "0.6"){
			progress_next_cross.state = "0.7"
		} else if(progress_next_cross.state == "0.7"){
			progress_next_cross.state = "0.8"
		} else if(progress_next_cross.state == "0.8"){
			progress_next_cross.state = "0.9"
		} else if(progress_next_cross.state == "0.9"){
			progress_next_cross.state = "1.0"
		} else {
			progress_next_cross.state = "0.1"
		}
	}

	ProgressBar {
		id: bar
		width: 25
		height: 100
		orientation: 0
		value: 0.7

		MouseArea {
			anchors.fill: parent
			onClicked: { move() }
		}
	}

	states: [
		State {
			name: "0.1"
			PropertyChanges { target: bar; value: 0.1 }
		},
		State {
			name: "0.2"
			PropertyChanges { target: bar; value: 0.2 }
		},
		State {
			name: "0.3"
			PropertyChanges { target: bar; value: 0.3 }
		},
		State {
			name: "0.4"
			PropertyChanges { target: bar; value: 0.4 }
		},
		State {
			name: "0.5"
			PropertyChanges { target: bar; value: 0.5 }
		},
		State {
			name: "0.6"
			PropertyChanges { target: bar; value: 0.6 }
		},
		State {
			name: "0.7"
			PropertyChanges { target: bar; value: 0.7 }
		},
		State {
			name: "0.8"
			PropertyChanges { target: bar; value: 0.8 }
		},
		State {
			name: "0.9"
			PropertyChanges { target: bar; value: 0.9 }
		},
		State {
			name: "1.0"
			PropertyChanges { target: bar; value: 1.0 }
		}
	]
}
