local MainSceneRes = "res/playGame.csb";          -- ��ʼ��Ϸ����
local PinRes       = "res/pin.csb";               -- ��ģ��
local ReadyPinRes  = "res/readyPin.csb";          -- ׼��������ģ��
local ReadyPinPng  = "failure-sk%d.png";          -- ���������ʽͼƬ
local gameBgMusic  = "res/bgSound.mp3";           -- ��������
local winMusic     = "res/win.mp3";               -- ʤ������
local lostMusic    = "res/lost.mp3";              -- ʧ������
local shootMusic   = "res/shoot.mp3";             -- �������
local openMusicRes  = "publicLayer- volume1.png"; -- ������ͼ��
local closeMusicRes = "publicLayer- volume2.png"; -- �ر�����ͼ��

local MainScene = class("MainScene", function()
    return cc.Layer:create()
end)

-- ��������
function MainScene:createScene()
    local scene = cc.Scene:create()
    scene:addChild(self)
    return scene
end

-- ���캯��
function MainScene:ctor()
    -- ע��enter��exit�¼�
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:_onEnter()
        elseif state == "exit" then
            self:_onExit()
        end
    end)
    self:addChild(cc.CSLoader:createNode(MainSceneRes));
    self.uiHelp   = require("UIHelper"):new();
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    --������������
    if tonumber(self.cur_userData.sound) == 2 then
        AudioEngine.playMusic(gameBgMusic, true);
    else
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    end
    
    --������
    self.pin_plane = self.uiHelp:seekChild(self,"Panel_7");
    self.allPin_rotation = {};
    self.allStage_num = 50;
    self:setBall(self.cur_userData.curStage);
    self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel); 
    --����Ƿ�ʹ�ù�ɳ©
    self.isGlassTime = true;
    --������ڵ�״̬
    self.playState = true;
    -- ����¼�
    self.uiHelp:seekChild(self, "playGameBg"):addTouchEventListener(handler(self,self.insertPin));
    self.uiHelp:seekChild(self, "expression_bg"):addTouchEventListener(handler(self,self.insertPin));
    self.uiHelp:seekChild(self,"toMainScene1"):addClickEventListener(handler(self,self.toMainScene));
    self.uiHelp:seekChild(self,"toMainScene2"):addClickEventListener(handler(self,self.toMainScene));
    self.uiHelp:seekChild(self,"resurrection_no"):addClickEventListener(handler(self,self.resurrection_no));
    self.uiHelp:seekChild(self,"resurrection_yes"):addClickEventListener(handler(self,self.resurrection_yes));
    self.uiHelp:seekChild(self,"toNextStage"):addClickEventListener(handler(self,self.toNextStage));
    self.uiHelp:seekChild(self,"toRestart"):addClickEventListener(handler(self,self.toRestart));
    self.uiHelp:seekChild(self,"rev_yes"):addClickEventListener(handler(self,self.rev_yes));
    self.uiHelp:seekChild(self,"rev_no"):addClickEventListener(handler(self,self.rev_no));
    self.uiHelp:seekChild(self,"hourglass_use"):addClickEventListener(handler(self,self.hourglass_use));
    self.uiHelp:seekChild(self,"pin_use"):addClickEventListener(handler(self,self.pin_use));
    self.uiHelp:seekChild(self,"revglass_yes"):addClickEventListener(handler(self,self.revglass_yes));
    self.uiHelp:seekChild(self,"revglass_no"):addClickEventListener(handler(self,self.revglass_no));
    self.uiHelp:seekChild(self,"revpin_yes"):addClickEventListener(handler(self,self.revpin_yes));
    self.uiHelp:seekChild(self,"revpin_no"):addClickEventListener(handler(self,self.revpin_no));
    self.uiHelp:seekChild(self,"voice_bnt"):addClickEventListener(handler(self,self.voice_bnt));
    self.uiHelp:seekChild(self,"confirmSure"):addClickEventListener(handler(self,self.confirmSure));
    self.uiHelp:seekChild(self,"confirmClose"):addClickEventListener(handler(self,self.confirmClose));
end

-- ���볡��
function MainScene:_onEnter()
    
end

-- �˳�����
function MainScene:_onExit()  
end

--���½���
function MainScene:init()
    local newScene = require("views.MainScene"):new():createScene();
    local transition = cc.TransitionFade:create(0.01,newScene);
    cc.Director:getInstance():replaceScene(transition);
end


-- ����ת���������ʹ����������
-- @param stage_num ��ǰ�Ĺ���
function  MainScene:setBall(stage_num)
    self.cur_userData = self.userData:getUserData();
    local tempArr = stage_configure[tonumber(stage_num)];
    --��ǰ�������
    local pin_num = tempArr[1];
    --��ǰ���ת������
    local rotatePoint = 360;
    --ÿ��֦�ɸ��ĽǶ�
    local Rotation = 360/pin_num;
    for i = 1,pin_num do
        local temp_pin = cc.CSLoader:createNode(PinRes);
        local temp_Rotation = Rotation * (i-1);
        temp_pin:setRotation(temp_Rotation);
        self.pin_plane:addChild(temp_pin);
        --���Ƕȱ�������
        self:saveRotation(temp_Rotation);
    end
    --���ô�������
    self:setPinPlane(tempArr[2]);
    --��������ת��
    self:setRotationSpeed(tonumber(stage_num),false);
    --���ùؿ�����
    self.uiHelp:seekChild(self,"stage_num"):setString(self.cur_userData.curStage);

    --��һ�ν�����Ϸ����ʾ��ȡ�����
    if  tonumber(self.cur_userData.revGift) == 0  then
        local layer = self.uiHelp:seekChild(self,"rev_gift");
        self.uiHelp:setTanChuang(self,layer);
    end
end

-- ����ת��
-- @param stage_num ��ǰ�Ĺؿ���
-- @param speed     ��ǰ���ٶȱ���{true:����  false:������}
function MainScene:setRotationSpeed(stage_num,isHalfSpeed)
    local tempArr = stage_configure[tonumber(stage_num)];
    --Ĭ��ת��һȦ����Ҫ��ʱ��
    local SpeedTime = 4;
    local curSpeedTime = SpeedTime/tempArr[3];
    if isHalfSpeed then
        curSpeedTime = curSpeedTime *2;
    end
    --��ǰ���ת������
    if tempArr[4] == 1 then
        self.rotatePoint = 360;
    else
        self.rotatePoint = -360;
    end
    local rotateAction = cc.RotateBy:create(curSpeedTime,self.rotatePoint);
    self.pin_plane:runAction(cc.RepeatForever:create(rotateAction));
end

-- ���ô�������
-- @param readyPin_num �������������
function  MainScene:setPinPlane(readyPin_num)
    --���÷����������
    self.readyPin_plane  = self.uiHelp:seekChild(self,"usePin_panel");
    --������������߶�   
    local pinHeight = 60;
    --��ʼ����
    local posX = self.readyPin_plane:getContentSize().width/2;
    local posY = self.readyPin_plane:getContentSize().height - pinHeight/2; 
    --ƫ����
    local moveY = pinHeight;

    for i = readyPin_num,1,-1 do
        local temp_pin   = cc.CSLoader:createNode(ReadyPinRes);
        local random_num = math.random(0,5);
        self.uiHelp:seekChild(temp_pin,"bg"):loadTexture(string.format(ReadyPinPng,random_num),UI_TEX_TYPE_PLIST);
        self.uiHelp:seekChild(temp_pin,"bg"):setName("bg"..random_num);
        temp_pin:setPosition(cc.p(posX,posY));
        posY = posY - moveY;
        self.uiHelp:seekChild(temp_pin,"readyBall_num"):setString(i);
        temp_pin:setTag(i);
        self.readyPin_plane:addChild(temp_pin);
    end
end

--����嵽���·�
function MainScene:insertPin(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if #self.readyPin_plane:getChildren() > 0 then
            local temp_pin = cc.CSLoader:createNode(PinRes);
            local allRotation = self.pin_plane:getRotation();
            --��ǰ��ĽǶ�
            local curRotation = self:getPinRotation();
            local insertRotation = 0;
            if allRotation > 0 then
               if allRotation%360 >=  curRotation then
                    insertRotation = 360 - allRotation%360;
               else
                    insertRotation = allRotation%360;
               end             
            elseif allRotation < 0 then
                if math.abs(allRotation%360) >=  curRotation then
                    insertRotation = 360 - math.abs(allRotation%360);
                else
                    insertRotation = math.abs(allRotation%360);
                end
            else
                insertRotation = 0;
            end
            --������ײ����
            if self:impactCheck(insertRotation) then
                if AudioEngine.isMusicPlaying () then
                    AudioEngine.playEffect(lostMusic);
                end

                local layer = self.uiHelp:seekChild(self,"resurrection");
                self.uiHelp:setTanChuang(self,layer);
                self:playInsertPin(2);
                self.playState = false;
            else
                if AudioEngine.isMusicPlaying () then
                    AudioEngine.playEffect(shootMusic);
                end
                self:playInsertPin(3);
                --��ȡ��ǰ��ɾ���������
                local pin_obj =  self.readyPin_plane:getChildByTag(#self.readyPin_plane:getChildren());
                local pin_name = self.uiHelp:seekChild(pin_obj,"ready_panel"):getChildByTag(999999):getName();
                local name_num = string.sub(pin_name,-1,-1);
                self.uiHelp:seekChild(temp_pin,"pin"):loadTexture("failure-z"..name_num..".png",UI_TEX_TYPE_PLIST);
                --���ýǶ�
                temp_pin:setRotation(insertRotation);
                self.pin_plane:addChild(temp_pin);
                --ɾ����������
                self:delReadyPin();
                --���浱ǰ����curRotation�ڵĽǶȵ�����
                self:saveRotation(insertRotation);
            end
        end
    elseif eventType == ccui.TouchEventType.moved then
        
    elseif eventType == ccui.TouchEventType.ended then
        
    elseif eventType == ccui.TouchEventType.canceled then
       
    end
end


-- ���Ÿ��ֶ���
-- @param playStyle{1:��Ϸʤ��,2:��Ϸʧ��,3:������}
function MainScene:playInsertPin(playStyle)
    local face = self.uiHelp:seekChild(self,"expression_img");
    face:stopAllActions();
    if     playStyle == 1 then
        face:loadTexture("failure-sl.png",UI_TEX_TYPE_PLIST);
    elseif playStyle == 2 then
        face:loadTexture("failure-gl.png",UI_TEX_TYPE_PLIST);
    else
        local function action()
            face:loadTexture("failure-jz.png",UI_TEX_TYPE_PLIST);
        end
        local function action1()
            face:loadTexture("failure-zc.png",UI_TEX_TYPE_PLIST);
        end
        face:runAction(cc.Sequence:create(cc.CallFunc:create(action),cc.DelayTime:create(0.5),cc.CallFunc:create(action1)));
    end
end

--ɾ�����������
function MainScene:delReadyPin()
    self.cur_userData = self.userData:getUserData();
    --ƫ����
    local moveY = 60;
    self.readyPin_plane:removeChildByTag(#self.readyPin_plane:getChildren(),true);
    local child = self.readyPin_plane:getChildren();
    for i = 1,#child do
        child[i]:setPositionY(child[i]:getPositionY() + moveY);
    end
    if #self.readyPin_plane:getChildren() == 0 then
        --��ȡ��ǰ�ؿ�
        local Stage =  self.cur_userData.curStage;
        cc.UserDefault:getInstance():setIntegerForKey(string.format("stage_%d",Stage),3);
        Stage = Stage +1;
        cc.UserDefault:getInstance():setIntegerForKey(string.format("stage_%d",Stage),2);
        cc.UserDefault:getInstance():setIntegerForKey("curStage",Stage);
        self:playInsertPin(1);
        if Stage <= self.allStage_num then
            local layer = self.uiHelp:seekChild(self,"playSucc");
            self.uiHelp:setTanChuang(self,layer);
            if AudioEngine.isMusicPlaying () then
                AudioEngine.playEffect(winMusic);
            end
        else
            local newScene = require("views.StartScene"):new():createScene();
            local transition = cc.TransitionFade:create(0.5,newScene);
            cc.Director:getInstance():replaceScene(transition);
        end
    end
end

-- ��ײ���
-- @param  insertRotation ��ǰ�Ĳ���Ƕ�
-- return {true:��ײ false:δ��ײ}
function MainScene:impactCheck(insertRotation)
     for i = 1,#self.allPin_rotation do
        if (insertRotation >= self.allPin_rotation[i][1]) and (insertRotation <= self.allPin_rotation[i][2]) then
            return true;
        end
     end
     return false;
end

-- ��ȡ��ǰ��Ƕ�
function MainScene:getPinRotation()
    local pin_node = cc.CSLoader:createNode(PinRes);
    local pin = self.uiHelp:seekChild(pin_node,"pin");
    local pin_x = pin:getContentSize().width/2;
    local pin_y = pin:getContentSize().height + math.abs(pin:getPositionY()) - pin_x;
    local tan = pin_x/pin_y;
    local radina = math.atan(tan);
    local angle =  math.ceil(180/(math.pi/radina));
    return angle *1.8;
end

-- ��ȡ���ǶȺ���С�Ƕ�
-- @ param rotation_num  1:{���Ƕ�},2:{��С�Ƕ�}
function MainScene:getRotationNum(rotation_num,insertRotation)
     --��ȡ��ǰ��ĽǶ�
    local curRotation = self:getPinRotation();
    local temp_num = 0;
    if rotation_num == 1 then
        temp_num = insertRotation + curRotation;
    else
        temp_num = insertRotation - curRotation;
    end 
    return temp_num;
end

-- ���Ƕ������¼��������
-- @param insertRotation ����ĽǶ�
function MainScene:saveRotation(insertRotation)
    local temp_arr = {};
    local curRotation_max = self:getRotationNum(1,insertRotation);
    local curRotation_min = self:getRotationNum(2,insertRotation);
    table.insert(temp_arr,table.getn(temp_arr) + 1,curRotation_min);
    table.insert(temp_arr,table.getn(temp_arr) + 1,curRotation_max);
    table.insert(self.allPin_rotation,table.getn(self.allPin_rotation) + 1,temp_arr);
end

-- ���õ�������
-- @param  glassTime_num ɳ©����
-- @param  scalpel_num   ����������
function MainScene:setPropNum(glassTime_num,scalpel_num)
    self.uiHelp:seekChild(self,"hourglass_num"):setString(glassTime_num);
    self.uiHelp:seekChild(self,"pin_num"):setString(scalpel_num);
end

--����������
function MainScene:toMainScene()
    self.uiHelp:seekChild(self,"playSucc"):setVisible(false);
    self.uiHelp:seekChild(self,"playFail"):setVisible(false);

    local newScene = require("views.StartScene"):new():createScene();
    local transition = cc.TransitionFade:create(0.5,newScene);
    cc.Director:getInstance():replaceScene(transition);
end

--��һ��
function MainScene:toNextStage()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self:init();
end

--���¿�ʼ
function MainScene:toRestart()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self:init();
end

--������
function MainScene:resurrection_no()
    self.uiHelp:seekChild(self,"resurrection"):setVisible(false);
    local layer = self.uiHelp:seekChild(self,"playFail");
    self.uiHelp:setTanChuang(self,layer);
end

--��Ҹ���
function MainScene:toResurrection()
    if not self.playState then
        local face = self.uiHelp:seekChild(self,"expression_img");
        face:loadTexture("failure-zc.png",UI_TEX_TYPE_PLIST);
        self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
        self.uiHelp:seekChild(self,"playFail"):setVisible(false);
        self.uiHelp:seekChild(self,"resurrection"):setVisible(false);
        self:confirmClose();
        self.playState = true;
    end
end

--�������
function  MainScene:resurrection_yes()
    local tag =  1;
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","3",function(result)
           self:toResurrection();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer,tag);
    end
end

--�ر���ȡ����
function MainScene:rev_no()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_gift"):setVisible(false);
end

--�����ȡ���
function MainScene:toRevGift()
    self.cur_userData = self.userData:getUserData();
    cc.UserDefault:getInstance():setIntegerForKey("revGift",1);
    cc.UserDefault:getInstance():setIntegerForKey("glassTime", tonumber(self.cur_userData.glassTime) + 3);
    cc.UserDefault:getInstance():setIntegerForKey("scalpel", tonumber(self.cur_userData.scalpel) + 10);
    self.cur_userData = self.userData:getUserData();
    self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel);
    self:confirmClose();
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_gift"):setVisible(false);
    self:confirmClose();
end

--�����ȡ���
function MainScene:rev_yes()
    local tag = 2;
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","2",function(result)
            self:toRevGift();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer,tag);
    end
end

--ʹ��ɳ©
function  MainScene:hourglass_use()
    self.cur_userData = self.userData:getUserData();
    if tonumber(self.cur_userData.glassTime) > 0 then
        if self.isGlassTime then
            self.isGlassTime = false;
            cc.UserDefault:getInstance():setIntegerForKey("glassTime", tonumber(self.cur_userData.glassTime) - 1);
            self:setRotationSpeed(self.cur_userData.curStage,true);
            self.cur_userData = self.userData:getUserData();
            self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel);
        end
    else 
        local layer = self.uiHelp:seekChild(self,"rev_glasstime");
        self.uiHelp:setTanChuang(self,layer);
    end
end

--ʹ��������
function  MainScene:pin_use()
    self.cur_userData = self.userData:getUserData();
    if tonumber(self.cur_userData.scalpel) > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("scalpel", tonumber(self.cur_userData.scalpel) - 1);
        self:delReadyPin();
        self.cur_userData = self.userData:getUserData();
        self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel);
    else 
        local layer = self.uiHelp:seekChild(self,"rev_pin");
        self.uiHelp:setTanChuang(self,layer);
    end
end

--�ر�©������
function  MainScene:revglass_no()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_glasstime"):setVisible(false);
end

--����©��
function MainScene:addRevglass()
    self.cur_userData = self.userData:getUserData();
    cc.UserDefault:getInstance():setIntegerForKey("glassTime", tonumber(self.cur_userData.glassTime) + 3);
    self.cur_userData = self.userData:getUserData();
    self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel);
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_glasstime"):setVisible(false);
    self:confirmClose();
end

--��ȡɳ©
function MainScene:revglass_yes()
    local tag = 3;
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","1",function(result)
            self:addRevglass();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer,tag);
    end
end

--�ر�����������
function  MainScene:revpin_no()
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_pin"):setVisible(false);
end

--����������
function MainScene:addRevpin()
    self.cur_userData = self.userData:getUserData();
    cc.UserDefault:getInstance():setIntegerForKey("scalpel", tonumber(self.cur_userData.scalpel) + 10);
    self.cur_userData = self.userData:getUserData();
    self:setPropNum(self.cur_userData.glassTime,self.cur_userData.scalpel);
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self.uiHelp:seekChild(self,"rev_pin"):setVisible(false);
    self:confirmClose();
end

--��ȡ������
function MainScene:revpin_yes()
   local tag = 4;
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","0",function(result)
            self:addRevpin();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer,tag);
    end
end

--ȷ�Ϲ���
function MainScene:confirmSure(sender)
    local arr = {"3","2","1","0"};
    SDKManager.pay("2000",arr[tonumber(sender:getTag())],function(result)
        if sender:getTag() == 1 then 
            self:toResurrection();
        elseif sender:getTag() == 2 then
            self:toRevGift();
        elseif sender:getTag() == 3 then
            self:addRevglass();
        elseif sender:getTag() == 4 then
            self:addRevpin();
        end
    end);
end

--����ȷ��ȡ��
function MainScene:confirmClose()
    self.uiHelp:seekChild(self,"mask_layer2"):setVisible(false);
    self.uiHelp:seekChild(self,"confirm_bnt"):setVisible(false);
end

--��������
function MainScene:voice_bnt()
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    if AudioEngine.isMusicPlaying () then
        cc.UserDefault:getInstance():setIntegerForKey("sound",1);
        AudioEngine.stopMusic();
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    else
        cc.UserDefault:getInstance():setIntegerForKey("sound",2);
        AudioEngine.playMusic(gameBgMusic,true);
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(openMusicRes,UI_TEX_TYPE_PLIST);
    end
end


return MainScene
