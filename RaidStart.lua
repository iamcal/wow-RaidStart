
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
RaidStart.info = {};
RaidStart.last_check = 0;
RaidStart.time_between_checks = 2;

function RaidStart.OnReady()

	-- set up default options
	_G.RaidStartPrefs = _G.RaidStartPrefs or {};

	for k,v in pairs(RaidStart.default_options) do
		if (not _G.RaidStartPrefs[k]) then
			_G.RaidStartPrefs[k] = v;
		end
	end

	RaidStart.CreateUIFrame();
	RaidStart.RebuildFrame();
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

	if (RaidStart.last_check + RaidStart.time_between_checks < GetTime()) then
		RaidStart.last_check = GetTime();
		RaidStart.PeriodicUpdate();
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

	if (event == 'GROUP_ROSTER_UPDATE')then
		if (RaidStart.fully_loaded) then
			RaidStart.RefreshState();
		end
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
	--RaidStart.Cover:SetFrameLevel(128);
	RaidStart.Cover:SetPoint("TOPLEFT", 0, 0);
	RaidStart.Cover:SetWidth(_G.RaidStartPrefs.frameW);
	RaidStart.Cover:SetHeight(_G.RaidStartPrefs.frameH);
	RaidStart.Cover:EnableMouse(true);
	RaidStart.Cover:RegisterForClicks("AnyUp");
	RaidStart.Cover:RegisterForDrag("LeftButton");
	RaidStart.Cover:SetScript("OnDragStart", RaidStart.OnDragStart);
	RaidStart.Cover:SetScript("OnDragStop", RaidStart.OnDragStop);
	RaidStart.Cover:SetScript("OnClick", RaidStart.OnClick);

	RaidStart.ColorIn(RaidStart.Cover, 1, 0.5, 0, 0.5);

	if (RaidStartPrefs.hide) then
		RaidStart.ShutItDown();
	else
		RaidStart.StartItUp();
	end
end

function RaidStart.StartItUp()
	RaidStart.UIFrame:Show();
	RaidStartPrefs.hide = false;
end

function RaidStart.ShutItDown()
	RaidStart.UIFrame:Hide();
	RaidStartPrefs.hide = true;
end

function RaidStart.ColorIn(frame, r, g, b, a)

	frame.texture = RaidStart.UIFrame:CreateTexture("ARTWORK");
	frame.texture:SetAllPoints(frame);
	frame.texture:SetTexture(r, g, b);
	frame.texture:SetAlpha(a);
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
end

function RaidStart.RebuildFrame()

	local members = {
		"Fflur",
		"Abdar",
		"Jonymill",
		"Emage",
		"Abejas",
	};

	RaidStart.ClearFrames();

	local i, v;
	local y = -8;

	for i,v in ipairs(members) do

		RaidStart.info[v] = {};
		RaidStart.info[v].label = RaidStart.CreateLabel(v, 8, y);
		RaidStart.info[v].status = RaidStart.CreateLabel('Status', 100, y);
		RaidStart.info[v].button = RaidStart.CreateButton('Invite', 100, y+4, 60);
		RaidStart.info[v].button:SetScript("OnClick", function()
			InviteUnit(v);
			RaidStart.info[v].last_invite = GetTime();
			RaidStart.RefreshState();
		end);
		RaidStart.info[v].last_invite = 0;

		y = y - 24;
	end

	--RaidStart.UIFrame:SetWidth();
	RaidStart.UIFrame:SetHeight(0-y);
	RaidStart.Cover:SetAllPoints(RaidStart.UIFrame);
end

function RaidStart.ClearFrames()

end

function RaidStart.CreateLabel(txt, x, y)

	local lbl = RaidStart.Cover:CreateFontString(nil, "OVERLAY");
	lbl:SetPoint("TOPLEFT", RaidStart.Cover, "TOPLEFT", x, y);
	lbl:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	lbl:SetText(txt);
	lbl:SetTextColor(1,1,1,1);
	RaidStart.SetFontSize(lbl, 14);

RaidStart.ColorIn(lbl, 0, 0, 1, 0.5);

	return lbl;
end

function RaidStart.CreateButton(txt, x, y, w)

	local btn = CreateFrame("Button", id, RaidStart.Cover, "UIPanelButtonTemplate");
	btn:SetPoint("TOPLEFT", x, y);
	btn:SetWidth(w);
	btn:SetHeight(20);
	--b:SetNormalTexture(texture);

	btn.text = btn:GetFontString();
	btn.text:SetPoint("LEFT", btn, "LEFT", 7, 0);
	btn.text:SetPoint("RIGHT", btn, "RIGHT", -7, 0);
	btn.text:SetText(txt);

	btn:RegisterForClicks("AnyDown");
	btn:SetScript("OnClick", function()
		print("btn click");
	end);
	btn:EnableMouse();

	return btn;
end

function RaidStart.PeriodicUpdate()

	--print("RS Periodic");
	RaidStart.RefreshState();
end

function RaidStart.RefreshState()

	if (RaidStartPrefs.hide) then
		return;
	end

	print("Refresh state");

	--
	-- convert to raid?
	--

	if (GetNumGroupMembers() > 0 and not IsInRaid() and UnitIsGroupLeader("player")) then
		ConvertToRaid();
	end


	local num, i;

	--
	-- get list of people in group
	--

	local members = {};
	num = GetNumGroupMembers();
	for i=1, num do
		local name = GetRaidRosterInfo(i);

		--print("In group: "..name);
		members[name] = 1;
	end


	--
	-- get list of people online in guild
	--

	local onlines = {};
	num = GetNumGuildMembers();
	for i=1, num do
		local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i);
		if (online) then

			--print("Guildie online: "..name);
			onlines[name] = 1;
		end
	end


	--
	-- update button/label status
	--

	local i, v;
	for i,v in pairs(RaidStart.info) do

		if (members[i]) then

			RaidStart.info[i].status:Show();
			RaidStart.info[i].status:SetText("In Group");
			RaidStart.info[i].button:Hide();

		elseif (not onlines[i]) then

			RaidStart.info[i].status:Show();
			RaidStart.info[i].status:SetText("Offline");
			RaidStart.info[i].button:Hide();

		else

			local elapsed = GetTime() - RaidStart.info[i].last_invite;
			if (elapsed < 10) then

				RaidStart.info[i].status:Show();
				RaidStart.info[i].status:SetText("Invited...");
				RaidStart.info[i].button:Hide();

			else

				RaidStart.info[i].status:Hide();
				RaidStart.info[i].button:Show();
			end
		end
	end

end

--UnitIsGroupAssistant("name"
--PromoteToAssistant("unit") -

SLASH_RAIDSTART1 = '/rs';
SLASH_RAIDSTART2 = '/raidstart';

function SlashCmdList.RAIDSTART(msg, editBox)

	if (RaidStartPrefs.hide) then

		RaidStart.StartItUp();
	else
		RaidStart.ShutItDown();
	end
end


RaidStart.EventFrame = CreateFrame("Frame");
RaidStart.EventFrame:Show();
RaidStart.EventFrame:SetScript("OnEvent", RaidStart.OnEvent);
RaidStart.EventFrame:SetScript("OnUpdate", RaidStart.OnUpdate);
RaidStart.EventFrame:RegisterEvent("ADDON_LOADED");
RaidStart.EventFrame:RegisterEvent("PLAYER_LOGIN");
RaidStart.EventFrame:RegisterEvent("PLAYER_LOGOUT");
RaidStart.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
