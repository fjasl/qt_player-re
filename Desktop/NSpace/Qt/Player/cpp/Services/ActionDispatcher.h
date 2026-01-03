#pragma once
#include <QObject>
#include "Connector.h"

class ActionDispatcher : public QObject
{
    Q_OBJECT
public:
    explicit ActionDispatcher(QObject *parent = nullptr);

    Q_INVOKABLE void dispatch(Action::Type action);

signals:
    void actionEmitted(Action::Type action);
};
