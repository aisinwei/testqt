TARGET = testqt
QT = quick aglextras qml
CONFIG += c++11 link_pkgconfig
PKGCONFIG += qlibwindowmanager qlibhomescreen

HEADERS += wmhandler.h

SOURCES += main.cpp \
	wmhandler.cpp

RESOURCES += \
    testqt.qrc \
    images/images.qrc

include(app.pri)
