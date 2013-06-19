
RaidStart = {};
RaidStart.fully_loaded = false;
RaidStart.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,

	-- sizing
	frameW = 200,
	frameH = 200,
};


function RaidStart.OnReady()

	-- set up default options
	_G.RaidStartPrefs = _G.RaidStartPrefs or {};

	for k,v in pairs(RaidStart.default_options) do
		if (not _G.RaidStartPrefs[k]) then
			_G.RaidStartPrefs[k] = v;
		end
	end

	RaidStart.CreateUIFrame();
end

function RaidStart.OnSaving()

	if (RaidStart.UIFrame) then
		local point, relativeTo, relativePoint, xOfs, yOfs = RaidStart.UIFrame:GetPoint()
		_G.RaidStartPrefs.frameRef = relativePoint;
		_G.RaidStartPrefs.frameX = xOfs;
		_G.RaidStartPrefs.frameY = yOfs;
	end
end

function RaidStart.OnUpdate()
	if (not RaidStart.fully_loaded) then
		return;
	end

	if (RaidStartPrefs.hide) then 
		return;
	end

	RaidStart.UpdateFrame();
end

function RaidStart.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'RaidStart' then
			RaidStart.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then

		RaidStart.fully_loaded = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then
		RaidStart.OnSaving();
		return;
	end
end

function RaidStart.CreateUIFrame()

	-- create the UI frame
	RaidStart.UIFrame = CreateFrame("Frame",nil,UIParent);
	RaidStart.UIFrame:SetFrameStrata("BACKGROUND")
	RaidStart.UIFrame:SetWidth(_G.RaidStartPrefs.frameW);
	RaidStart.UIFrame:SetHeight(_G.RaidStartPrefs.frameH);

	-- make it black
	RaidStart.UIFrame.texture = RaidStart.UIFrame:CreateTexture();
	RaidStart.UIFrame.texture:SetAllPoints(RaidStart.UIFrame);
	RaidStart.UIFrame.texture:SetTexture(0, 0, 0);

	-- position it
	RaidStart.UIFrame:SetPoint(_G.RaidStartPrefs.frameRef, _G.RaidStartPrefs.frameX, _G.RaidStartPrefs.frameY);

	-- make it draggable
	RaidStart.UIFrame:SetMovable(true);
	RaidStart.UIFrame:EnableMouse(true);

	-- create a button that covers the entire addon
	RaidStart.Cover = CreateFrame("Button", nil, RaidStart.UIFrame);
	RaidStart.Cover:SetFrameLevel(128);
	RaidStart.Cover:SetPoint("TOPLEFT", 0, 0);
	RaidStart.Cover:SetWidth(_G.RaidStartPrefs.frameW);
	RaidStart.Cover:SetHeight(_G.RaidStartPrefs.frameH);
	RaidStart.Cover:EnableMouse(true);
	RaidStart.Cover:RegisterForClicks("AnyUp");
	RaidStart.Cover:RegisterForDrag("LeftButton");
	RaidStart.Cover:SetScript("OnDragStart", RaidStart.OnDragStart);
	RaidStart.Cover:SetScript("OnDragStop", RaidStart.OnDragStop);
	RaidStart.Cover:SetScript("OnClick", RaidStart.OnClick);

	-- add a main label - just so we can show something
	RaidStart.Label = RaidStart.Cover:CreateFontString(nil, "OVERLAY");
	RaidStart.Label:SetPoint("CENTER", RaidStart.UIFrame, "CENTER", 2, 0);
	RaidStart.Label:SetJustifyH("LEFT");
	RaidStart.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	RaidStart.Label:SetText(" ");
	RaidStart.Label:SetTextColor(1,1,1,1);
	RaidStart.SetFontSize(RaidStart.Label, 20);
end

function RaidStart.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function RaidStart.OnDragStart(frame)
	RaidStart.UIFrame:StartMoving();
	RaidStart.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function RaidStart.OnDragStop(frame)
	RaidStart.UIFrame:StopMovingOrSizing();
	RaidStart.UIFrame.isMoving = false;
end

function RaidStart.OnClick(self, aButton)
	if (aButton == "RightButton") then
		print("show menu here!");
	end
end

function RaidStart.UpdateFrame()

	-- update the main frame state here
	RaidStart.Label:SetText(string.format("%d", GetTime()));
end


RaidStart.EventFrame = CreateFrame("Frame");
RaidStart.EventFrame:Show();
RaidStart.EventFrame:SetScript("OnEvent", RaidStart.OnEvent);
RaidStart.EventFrame:SetScript("OnUpdate", RaidStart.OnUpdate);
RaidStart.EventFrame:RegisterEvent("ADDON_LOADED");
RaidStart.EventFrame:RegisterEvent("PLAYER_LOGIN");
RaidStart.EventFrame:RegisterEvent("PLAYER_LOGOUT");