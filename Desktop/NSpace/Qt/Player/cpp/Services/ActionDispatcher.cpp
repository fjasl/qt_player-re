#include "ActionDispatcher.h"

ActionDispatcher::ActionDispatcher(QObject *parent)
    : QObject(parent)
{
}

void ActionDispatcher::dispatch(Action::Type action)
{
    emit actionEmitted(action);
}
