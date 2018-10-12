TARGET = testqt
QT = quick aglextras qml
CONFIG += c++11 link_pkgconfig
#PKGCONFIG += 

#HEADERS += 

SOURCES += main.cpp

RESOURCES += \
    testqt.qrc \
    images/images.qrc

include(app.pri)
