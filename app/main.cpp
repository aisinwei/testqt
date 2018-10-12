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

#define USE_QTAGLEXTRAS			0
#define USE_QLIBWINDOWMANAGER	0

#if	USE_QTAGLEXTRAS
#include <QtAGLExtras/AGLApplication>
#elif USE_QLIBWINDOWMANAGER
#include <qlibwindowmanager.h>
#include <qlibhomescreen.h>
#else	// for only libwindowmanager
#include <libwindowmanager.h>
#include <libhomescreen.hpp>
#endif

#include <QtCore/QDebug>
#include <QtCore/QCommandLineParser>
#include <QtCore/QUrlQuery>
#include <QtCore/QSettings>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include <QQuickWindow>
#include <string>

#include <ilm/ivi-application-client-protocol.h>
#include <wayland-client.h>

#include "wmhandler.h"

using namespace std;

LibHomeScreen *hs;
LibWindowmanager *wm;
WmHandler *wmh;

const char *main_role = "testqt";
long port = 1700;
string token = string("hello");

int
init_wm(LibWindowmanager *wm)
{
	if(wm->init(port, token.c_str()) != 0) {
		return -1;
	}
	int id = wm->requestSurface(main_role);
	fprintf(stderr, "[testqt]get surface(%d)\n", id);
	if(id < 0) {
		return -1;
	}else{
		char buf[65];   // surface id is under 64bit(1.84E19,) so 65 is sufficient for buffer
		snprintf(buf, 65, "%d", id);
		setenv("QT_IVI_SURFACE_ID", buf, 1);
	}
	WMHandler wmh;
	wmh.on_visible = [](const char* role, bool visible){
		;
	};
	wmh.on_sync_draw = [wm](const char* role, const char* area, Rect rect) {
		fprintf(stderr, "[testqt]endDraw(%s)\n", role);
		wm->endDraw(role);
	};
	wm->setEventHandler(wmh);
	return 0;
}

int
init_hs(LibHomeScreen* hs){
	if(hs->init(port, token.c_str())!=0){
		return -1;
	}
	hs->set_event_handler(LibHomeScreen::Event_TapShortcut, [](json_object *object){
		const char *application_name = json_object_get_string(
			json_object_object_get(object, "application_name"));
		if(strcmp(application_name, "testqt") == 0)
		{
			fprintf(stderr, "[testqt]activateWindow @ TapShortcut)\n");
			wm->activateWindow(main_role);
		}
	});
	return 0;
}

int main(int argc, char *argv[])
{
#if	USE_QTAGLEXTRAS
	AGLApplication app(argc, argv);
	app.setApplicationName("testqt");
	app.setupApplicationRole("testqt");

	app.load(QUrl(QStringLiteral("qrc:/testqt.qml")));
	return app.exec();
#elif USE_QLIBWINDOWMANAGER
	QGuiApplication a(argc, argv);
	QString myname = QString("testqt");
	int port = 1700;
	QString token = "wm";
	QCoreApplication::setOrganizationDomain("LinuxFoundation");
	QCoreApplication::setOrganizationName("AutomotiveGradeLinux");
	QCoreApplication::setApplicationName(myname);
	QCoreApplication::setApplicationVersion("0.1.0");
	QCommandLineParser parser;
	parser.addPositionalArgument("port", a.translate("main", "port for binding"));
	parser.addPositionalArgument("secret", a.translate("main", "secret for binding"));
	parser.addHelpOption();
	parser.addVersionOption();
	parser.process(a);
	QStringList positionalArguments = parser.positionalArguments();
	if (positionalArguments.length() == 2) {
		port = positionalArguments.takeFirst().toInt();
		token = positionalArguments.takeFirst();
	}
	fprintf(stderr, "[testqt]app_name: %s, port: %d, token: %s.\n",
					myname.toStdString().c_str(),
					port,
					token.toStdString().c_str());
	// QLibWM
	QLibWindowmanager* layoutHandler = new QLibWindowmanager();
	int res;
	if((res = layoutHandler->init(port,token)) != 0){
		fprintf(stderr, "[testqt]init qlibwm err(%d)\n", res);
		return -1;
	}
	if((res = layoutHandler->requestSurface(myname)) != 0) {
		fprintf(stderr, "[testqt]request surface err(%d)\n", res);
		return -1;
	}
	layoutHandler->set_event_handler(QLibWindowmanager::Event_SyncDraw, [layoutHandler, myname](json_object *object) {
		layoutHandler->endDraw(myname);
	});
	layoutHandler->set_event_handler(QLibWindowmanager::Event_Visible, [layoutHandler, myname](json_object *object) {
		;
	});
	layoutHandler->set_event_handler(QLibWindowmanager::Event_Invisible, [layoutHandler, myname](json_object *object) {
		;
	});
	// QLibHS
	QLibHomeScreen* homescreenHandler = new QLibHomeScreen();
	homescreenHandler->init(port, token.toStdString().c_str());
	homescreenHandler->set_event_handler(QLibHomeScreen::Event_TapShortcut, [layoutHandler, myname](json_object *object){
		json_object *appnameJ = nullptr;
		if(json_object_object_get_ex(object, "application_name", &appnameJ))
		{
			const char *appname = json_object_get_string(appnameJ);
			if(myname == appname)
			{
				qDebug("Surface %s got tapShortcut\n", appname);
				layoutHandler->activateSurface(myname);
			}
		}
	});
	// Load qml
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/testqt.qml")));

	QObject *root = engine.rootObjects().first();
	QQuickWindow *window = qobject_cast<QQuickWindow *>(root);
	QObject::connect(window, SIGNAL(frameSwapped()), layoutHandler, SLOT(slotActivateSurface()));
	
	return a.exec();
#else	// for only libwindowmanager
	QGuiApplication app(argc, argv);
	
	if(argc > 2){
		port = strtol(argv[1], NULL, 10);
		token = argv[2];
	}
	fprintf(stderr, "[testqt]app_name: %s, port: %d, token: %s.\n", main_role, port, token.c_str());
	// LibWM
	wm = new LibWindowmanager();
	if(init_wm(wm)!=0){
		fprintf(stderr, "[testqt]init_wm failed\n");
		return -1;
	}else{
		fprintf(stderr, "[testqt]init_wm OK\n");
	}
	// LibHS
	hs = new LibHomeScreen();
	if(init_hs(hs)!=0){
		fprintf(stderr, "[testqt]init_hs failed\n");
		return -1;
	}else{
		fprintf(stderr, "[testqt]init_hs OK\n");
	}
	wmh = new WmHandler();
	wmh->init(wm, main_role);
	// Load qml
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/testqt.qml")));
	QObject *root = engine.rootObjects().first();
	QQuickWindow *window = qobject_cast<QQuickWindow *>(root);
	
	fprintf(stderr, "[testqt]wait for frame swap to activeWindow\n");
	QObject::connect(window, SIGNAL(frameSwapped()), wmh, SLOT(slotActivateWindow()));
	
	return app.exec();
#endif
}

