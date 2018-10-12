/*
 * Copyright (c) 2017 TOYOTA MOTOR CORPORATION
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef WMHANDLER_H
#define WMHANDLER_H
#include <QObject>
#include <QUrl>
#include <QVariant>
#include <string>
#include <vector>
#include <functional>
#include <libwindowmanager.h>

class WmHandler : public QObject {
Q_OBJECT
public:
    explicit WmHandler(QObject *parent = nullptr);
    ~WmHandler();

    WmHandler(const WmHandler &) = delete;
    WmHandler &operator=(const WmHandler &) = delete;

public:
    static WmHandler &instance();
    void init(LibWindowmanager *p_wm, const char *role);

public slots:
    void slotActivateWindow();

private:
    LibWindowmanager* mp_wm;
    const char *m_applabel;
	bool isActive;
};
#endif // WMHANDLER_H
