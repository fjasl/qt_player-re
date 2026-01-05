// AppLogic.cpp (原 LogicManager)
#include "PlayerModule.h"
#include "LogicManager.h"
#include "LifeStageModule.h"
void AppLogic::initAll() {
    // 像插拔插件一样加载不同领域的逻辑
    PlayerModule::init();
    LifeStageModule::init();
    // ... 以后增加新功能，只需在这里加一行 init
}
