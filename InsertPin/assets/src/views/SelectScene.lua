local SelectSceneRes = "res/selectGame.csb";      -- ѡ��ؿ�����
local StagePointRes  = "res/stageItem.csb";       -- �ؿ�ģ��
local onePageRes     = "levelLayer-o1.png";       -- ҳ��ѡ����ʽ
local twoPageRes     = "levelLayer-o2.png";       -- ҳ��δѡ����ʽ
local lockRes        = "levelLayer-y.png";        -- δ����
local openRes        = "levelLayer-open.png";     -- �ѿ���
local okRes          = "levelLayer-ok.png";       -- ��ͨ��
local openMusicRes   = "publicLayer- volume1.png"; -- ������ͼ��
local closeMusicRes  = "publicLayer- volume2.png"; -- �ر�����ͼ��

SelectScene = class("SelectScene", function()
    return cc.Layer:create()
end)

-- ��������
function SelectScene:createScene()
    local scene = cc.Scene:create()
    scene:addChild(self)
    return scene
end

-- ���캯��
function SelectScene:ctor()
    -- ע��enter��exit�¼�
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:_onEnter()
        elseif state == "exit" then
            self:_onExit()
        end
    end)
    self:addChild(cc.CSLoader:createNode(SelectSceneRes));
    self.uiHelp   = require("UIHelper"):new();
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    --��������ͼ��
    if tonumber(self.cur_userData.sound) ~= 2 then
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    end

    --ÿҳ�ؿ�������
    self.stage_num = 35;
    --�ܵĹؿ�����
    self.allStage_num = 50;
    --��ǰ�ؿ�ҳ��
    self.cur_page = 1;
    --���ҳ��
    self.end_page = math.ceil(self.allStage_num/self.stage_num);
    self.stage_panel = self.uiHelp:seekChild(self,"Panel_stage");
    --ÿ�ν����ؿ���
    self.open_num = 10;
    --����¼�
    self.uiHelp:seekChild(self, "left_bnt"):addClickEventListener(handler(self,self.leftPage));
    self.uiHelp:seekChild(self, "right_bnt"):addClickEventListener(handler(self,self.rightPage));
    self.uiHelp:seekChild(self, "openLock_bnt"):addClickEventListener(handler(self,self.openLock));
    self.uiHelp:seekChild(self, "openLock_close"):addClickEventListener(handler(self,self.openLock_close));
    self.uiHelp:seekChild(self, "voice_bnt"):addClickEventListener(handler(self,self.openOrCloseVoice));   
    self.uiHelp:seekChild(self,"confirmSure"):addClickEventListener(handler(self,self.confirmSure));
    self.uiHelp:seekChild(self,"confirmClose"):addClickEventListener(handler(self,self.confirmClose));
    --���û�����ҳ
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(false);
    listener:registerScriptHandler(handler(self,self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN );
    listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self);
    --Ĭ�����õ�һҳ�ǿ�ʼ�ؿ�
    self:toSetStagePos();
end

-- ���볡��
function SelectScene:_onEnter()
end
-- �˳�����
function SelectScene:_onExit()  
end

--�ؿ���
function SelectScene:leftPage()
    self.cur_page = self.cur_page -1;
    if self.cur_page < 1 then
        self.cur_page = 1;
    end
    self:showStage(self.cur_page);
end

--�ؿ��ҷ�
function SelectScene:rightPage()
    self.cur_page = self.cur_page + 1;
    if self.cur_page > self.end_page then
        self.cur_page = self.end_page;
    end
    self:showStage(self.cur_page);
end

--����
function SelectScene:toOpenLock()
    local endStage_num = 0;
    --��ǰ�������Ĺؿ�
    local curStage = self:getOpenStageNum();
    if (self.open_num + curStage) > self.allStage_num then
        endStage_num = self.allStage_num;
    else
        endStage_num = self.open_num + curStage;    
    end

    cc.UserDefault:getInstance():setIntegerForKey("curStage",endStage_num);
    for i = curStage,endStage_num do
        cc.UserDefault:getInstance():setIntegerForKey(string.format("stage_%d",i),2);
    end
    self.uiHelp:seekChild(self,"openLock"):setVisible(false);
    self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
    self:confirmClose();
    self:showStage(self.cur_page);
end


--�����ؿ�
function SelectScene:openLock()
    if GameConfig.confirm ==  0 then
        SDKManager.pay("2000","4",function(result)
            self:toOpenLock();
        end);
    else 
        local layer = self.uiHelp:seekChild(self,"confirm_bnt");
        self.uiHelp:confirmTanChuang(self,layer);
    end
end

--ȷ�Ϲ���
function SelectScene:confirmSure()
    SDKManager.pay("2000","4",function(result)
        self:toOpenLock();
    end);
end

--����ȷ��ȡ��
function SelectScene:confirmClose()
    self.uiHelp:seekChild(self,"mask_layer2"):setVisible(false);
    self.uiHelp:seekChild(self,"confirm_bnt"):setVisible(false);
end



--�رս����ؿ�
function  SelectScene:openLock_close()
     self.uiHelp:seekChild(self,"openLock"):setVisible(false);
     self.uiHelp:seekChild(self,"mask_layer"):setVisible(false);
end

--������Ϸ
function  SelectScene:enterGame(sender)
    self.cur_userData = self.userData:getUserData();
    if self.cur_userData.isPass[sender:getTag()] ~= 1 then
        cc.UserDefault:getInstance():setIntegerForKey("curStage", sender:getTag());        
        local newScene = require("views.MainScene"):new():createScene();
        local transition = cc.TransitionFade:create(0.5,newScene);
        cc.Director:getInstance():replaceScene(transition);
    else
        local openLock = self.uiHelp:seekChild(self,"openLock");
        self.uiHelp:setTanChuang(self,openLock);
    end
end

--��������
function SelectScene:openOrCloseVoice(sender)
    self.userData = require("userData"):new();
    self.cur_userData = self.userData:getUserData();
    if AudioEngine.isMusicPlaying () then
        cc.UserDefault:getInstance():setIntegerForKey("sound",1);
        AudioEngine.stopMusic();
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(closeMusicRes,UI_TEX_TYPE_PLIST);
    else
        cc.UserDefault:getInstance():setIntegerForKey("sound",2);
        AudioEngine.playMusic(bgMusic,true);
        self.uiHelp:seekChild(self, "voice_bnt"):loadTexture(openMusicRes,UI_TEX_TYPE_PLIST);
    end
end

--������ʼ
function SelectScene:onTouchBegan(touch,event)
    self.firstX = touch:getLocation().x;
    return true;  
end

--��������
function SelectScene:onTouchEnded(touch,event)
    local endX = self.firstX - touch:getLocation().x;
    --�������Ǵ�������
    if math.abs(endX) > 100 then
        if endX > 0 then
            self:rightPage();
        else
            self:leftPage();
        end
    end
end

--���ùؿ�λ��
function SelectScene:toSetStagePos()
    local stage = cc.CSLoader:createNode(StagePointRes);
    local item = self.uiHelp:seekChild(stage,"stage");
    --��ʼY����
    local posY = self.stage_panel:getPositionY() + item:getContentSize().height;
    --��ǰ�ڼ���  
    local curPosX = 1;
    local curPosY = 1;
    --ƫ����
    local moveX = item:getContentSize().width;
    local moveY = item:getContentSize().height * 1.2;
    for i = 1,self.stage_num do
        local temp_item = cc.CSLoader:createNode(StagePointRes);
        temp_item:setPosition(cc.p((curPosX - 1)* moveX,(posY - (curPosY-1) * moveY)));
        --���ؿ����ӵ���¼�
        self.uiHelp:seekChild(temp_item,"stage_bg"):addClickEventListener(handler(self,self.enterGame));
        self.stage_panel:addChild(temp_item);
        curPosX = curPosX + 1;
        if i%5 == 0 then
            curPosY = curPosY +1;
            curPosX = 1;
        end
    end
    --Ĭ����ʾ��һҳ
    self:showStage(1);
end

--��ʾ�ؿ�
--@param pageIndex �ڼ�ҳ
function SelectScene:showStage(pageIndex)
    self.cur_userData = self.userData:getUserData();
    --��ǰҳ��ؿ�����
    local num = 0;
    if pageIndex == self.end_page then
        num = self.allStage_num%self.stage_num;
    else
        num = self.stage_num;
    end
    --��ǰҳ�濪ʼ�ؿ�
    local curItems = self.stage_num * (pageIndex-1);   
    local all_stages = self.stage_panel:getChildren();
    for i = 1,self.stage_num do
        if pageIndex == self.end_page then
            if i > num then
                all_stages[i]:setVisible(false);
                self.uiHelp:seekChild(self,"onePage"):loadTexture(onePageRes,UI_TEX_TYPE_PLIST);
                self.uiHelp:seekChild(self,"twoPage"):loadTexture(twoPageRes,UI_TEX_TYPE_PLIST);
            end
        else
            all_stages[i]:setVisible(true);
            self.uiHelp:seekChild(self,"onePage"):loadTexture(twoPageRes,UI_TEX_TYPE_PLIST);
            self.uiHelp:seekChild(self,"twoPage"):loadTexture(onePageRes,UI_TEX_TYPE_PLIST);            
        end
        curItems = curItems + 1;
        local stage_bg = self.uiHelp:seekChild(all_stages[i],"stage_bg");
        stage_bg:setTag(curItems);
        if self.cur_userData.isPass[curItems] == 1 then
            self.uiHelp:seekChild(all_stages[i],"stage_font"):setVisible(false);
            stage_bg:loadTexture(lockRes,UI_TEX_TYPE_PLIST);
        else
            self.uiHelp:seekChild(all_stages[i],"stage_font"):setVisible(true);
            self.uiHelp:seekChild(all_stages[i],"stage_font"):setString(curItems);
            if self.cur_userData.isPass[curItems] == 2 then
                stage_bg:loadTexture(openRes,UI_TEX_TYPE_PLIST);
            elseif self.cur_userData.isPass[curItems] == 3 then
                stage_bg:loadTexture(okRes,UI_TEX_TYPE_PLIST);
            end
        end
    end
end

--��ȡ��ǰ�Ѿ������Ĺؿ�
function SelectScene:getOpenStageNum()
     self.cur_userData = self.userData:getUserData();
     local curStage_end = 0;
     for i=1,#self.cur_userData.isPass do
        if self.cur_userData.isPass[i] ~= 1 then
            curStage_end = curStage_end + 1;
        end
     end
     return curStage_end;
end

return SelectScene
