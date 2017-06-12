local startSceneRes = "res/startGame.csb";        -- ��ʼ��Ϸ����
local bgMusic       = "res/startSound.mp3"; -- ��������
local openMusicRes  = "publicLayer- volume1.png"; -- ������ͼ��
local closeMusicRes = "publicLayer- volume2.png"; -- �ر�����ͼ��

local startScene = class("startScene", function()
    return cc.Layer:create()
end)

-- ��������
function startScene:createScene()
    local scene = cc.Scene:create()
    scene:addChild(self)
    return scene
end

-- ���캯��
function startScene:ctor()
    -- ע��enter��exit�¼�
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:_onEnter()
        elseif state == "exit" then
            self:_onExit()
        end
    end)
    self:addChild(cc.CSLoader:createNode(startSceneRes));
    self.uiHelp = require("UIHelper"):new();
    
    --����ת��
    local rotationNode = self.uiHelp:seekChild(self,"rotation_node");
    local action = cc.RotateBy:create(4,360);
    rotationNode:runAction(cc.RepeatForever:create(action));

    -- ����¼�
    self.uiHelp:seekChild(self, "startGame_bnt"):addClickEventListener(handler(self,self.toSelectGame));
    self.uiHelp:seekChild(self, "gameVoice_bnt"):addClickEventListener(handler(self,self.selectVoice));
    self.uiHelp:seekChild(self,"rev_yes"):addClickEventListener(handler(self,self.rev_yes));
    self.uiHelp:seekChild(self,"rev_no"):addClickEventListener(handler(self,self.rev_no));
    self.uiHelp:seekChild(self,"confirmSure"):addClickEventListener(handler(self,self.confirmSure));
    self.uiHelp:seekChild(self,"confirmClose"):addClickEventListener(handler(self,self.confirmClose));
    --���ű�������
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    if tonumber(self.cur_userData.sound) == 2 then
        AudioEngine.playMusic(bgMusic, true);
    else
        self.uiHelp:seekChild(self, "gameVoice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    end
    
end

-- ���볡��
function startScene:_onEnter()
    --���볡����ʾ��ȡ���
    if  tonumber(self.cur_userData.revGift) == 0  then
        local layer = self.uiHelp:seekChild(self,"rev_gift");
        self.uiHelp:setTanChuang(self,layer);
    end
end
-- �˳�����
function startScene:_onExit()  
end

-- ѡ��ؿ�
function startScene:toSelectGame(sender)
    local newScene = require("views.SelectScene"):new():createScene();
    local transition = cc.TransitionFade:create(0.5,newScene);
    cc.Director:getInstance():replaceScene(transition);
end

--��������
function startScene:selectVoice(sender)
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    if AudioEngine.isMusicPlaying () then
        cc.UserDefault:getInstance():setIntegerForKey("sound",1);
        AudioEngine.stopMusic();
        self.uiHelp:seekChild(self, "gameVoice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    else
        cc.UserDefault:getInstance():setIntegerForKey("sound",2);
        AudioEngine.playMusic(bgMusic,true);
        self.uiHelp:seekChild(self, "gameVoice_bnt"):loadTexture(openMusicRes,UI_TEX_TYPE_PLIST);
    end

end

--Ϊ����������
function startScene:add_gift()
    self.cur_userData = self.userData:getUserData();
    cc.UserDefault:getInstance():setIntegerForKey("revGift",1);
    cc.UserDefault:getInstance():setIntegerForKey("glassTime", tonumber(self.cur_userData.glassTime) + 3);
    cc.UserDefault:getInstance():setIntegerForKey("scalpel", tonumber(self.cur_userData.scalpel) + 10);
    self:confirmClose();
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_gift"):setVisible(false);
end


--�����ȡ���
function startScene:rev_yes()
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","2",function(result)
            self:add_gift();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer);
    end
end

--�ر���ȡ����
function startScene:rev_no()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_gift"):setVisible(false);
end

--ȷ�Ϲ���
function startScene:confirmSure()
    SDKManager.pay("2000","2",function(result)
        self:add_gift();
    end);
end

--����ȷ��ȡ��
function startScene:confirmClose()
    self.uiHelp:seekChild(self,"mask_layer2"):setVisible(false);
    self.uiHelp:seekChild(self,"confirm_bnt"):setVisible(false);
end

return startScene
