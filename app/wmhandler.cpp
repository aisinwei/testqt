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

#include "wmhandler.h"
#include <unistd.h>


void WmHandler::init(LibWindowmanager *p_wm, const char *role)
{
	mp_wm = p_wm;
	m_applabel = role;
	fprintf(stderr, "[testqt]set label(%s) for activeWindow\n", role);
}

void WmHandler::slotActivateWindow() {
	if(!isActive){
		isActive = true;
		fprintf(stderr, "[testqt]activeWindow(%s) @ slot\n", m_applabel);
		mp_wm->activateWindow(m_applabel);
	}
}

WmHandler::WmHandler(QObject *parent)
    :QObject(parent), isActive(false)
{
}

WmHandler::~WmHandler() { }
