/****************************************************************************
 * This file is part of Hawaii.
 *
 * Copyright (C) 2015-2016 Pier Luigi Fiorini
 *
 * Author(s):
 *    Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 * $BEGIN_LICENSE:GPL2+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 ***************************************************************************/

#ifndef SESSIONINTERFACE_H
#define SESSIONINTERFACE_H

#include <QtCore/QThread>
#include <QtQml/QJSValue>

class Authenticator;
class CustomAuthenticator;
class SessionManager;

class SessionInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool canLock READ canLock CONSTANT)
    Q_PROPERTY(bool canStartNewSession READ canStartNewSession CONSTANT)
    Q_PROPERTY(bool canLogOut READ canLogOut CONSTANT)
    Q_PROPERTY(bool canPowerOff READ canPowerOff CONSTANT)
    Q_PROPERTY(bool canRestart READ canRestart CONSTANT)
    Q_PROPERTY(bool canSuspend READ canSuspend CONSTANT)
    Q_PROPERTY(bool canHibernate READ canHibernate CONSTANT)
    Q_PROPERTY(bool canHybridSleep READ canHybridSleep CONSTANT)
public:
    SessionInterface(SessionManager *sm, QObject *parent = 0);
    virtual ~SessionInterface();

    inline SessionManager *sessionManager() const {
        return m_sessionManager;
    }

    bool canLock() const;
    bool canStartNewSession() const;
    bool canLogOut() const;
    bool canPowerOff() const;
    bool canRestart() const;
    bool canSuspend() const;
    bool canHibernate() const;
    bool canHybridSleep() const;

Q_SIGNALS:
    void sessionLocked();
    void sessionUnlocked();

    void logOutRequested();
    void powerOffRequested();
    void restartRequested();
    void suspendRequested();
    void hibernateRequested();
    void hybridSleepRequested();
    void shutdownRequestCanceled();

public Q_SLOTS:
    void lockSession();
    void unlockSession(const QString &password, const QJSValue &callback);
    void startNewSession();
    void activateSession(int index);

    void requestLogOut();
    void requestPowerOff();
    void requestRestart();
    void requestSuspend();
    void requestHibernate();
    void requestHybridSleep();
    void cancelShutdownRequest();

    void logOut();
    void powerOff();
    void restart();
    void suspend();
    void hibernate();
    void hybridSleep();

private:
    SessionManager *m_sessionManager;
    Authenticator *m_authenticator;
    QThread *m_authenticatorThread;
    bool m_authRequested;


    bool m_canLock;
    bool m_canStartNewSession;
    bool m_canLogOut;
    bool m_canPowerOff;
    bool m_canRestart;
    bool m_canSuspend;
    bool m_canHibernate;
    bool m_canHybridSleep;

    friend class CustomAuthenticator;
};

#endif // SESSIONINTERFACE_H
