
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "UIHelper"
require "userData"
SDKManager =  require("SDKManager")

local function main()
    --��java��ע��lua����
    SDKManager.init();
    cc.Director:getInstance():runWithScene(require("views.StartScene"):new():createScene());
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
