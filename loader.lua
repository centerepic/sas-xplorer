local Request = nil
pcall(function()
	Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
end)

if not Request then
    Request = function(Table)
        local Response = {}
        Response.Body = game:HttpGet(Table.Url)
        return Response
    end
end

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local RobloxAPIDumpSources = {
    "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json",
    "https://raw.githubusercontent.com/centerepic/sas-xplorer/main/ROBLOX_API_DUMP_BACKUP.json"
}

local ClassIconOffsetsSource = "https://raw.githubusercontent.com/centerepic/sas-xplorer/main/Class_Icon_Offsets.json"

local ClassIconOffsets
local APIDump

do
    for _, Source in next, RobloxAPIDumpSources do
        local Result = Request(
            {Url = Source}
        ).Body

        if Result then
            local ResultDecoded = HttpService:JSONDecode(Result)
            if ResultDecoded then
                APIDump = ResultDecoded
                break
            end
        end
    end


    local ClassIconOffsetsJSON = Request(
            {Url = ClassIconOffsetsSource}
    ).Body

    ClassIconOffsets = HttpService:JSONDecode(ClassIconOffsetsJSON)
end -- Get class icon offsets

print("Checkpoint 1")

local function SetClassIcon(Image, ClassName)
    local ClassIcon = ClassIconOffsets[ClassName] or {ImageRectOffset = {0,0}}
	Image.Image = "rbxasset://textures/ClassImages.png"
    Image.ImageRectOffset = Vector2.new(table.unpack(ClassIcon.ImageRectOffset))
    Image.ImageRectSize = Vector2.new(16,16)
end

local function SetProperties(Instance, PropertiesTable)
    for i, v in next, PropertiesTable do
		Instance[i] = v
	end
end

-- local function GetProperties(Instance)
--     local Properties = {}

--     for _, Class in next, APIDump.Classes do
--         if Class.Name == Instance.ClassName then
--             for _, Member in ipairs(Class.Members) do
--                 if Member.MemberType == "Property" then
--                     pcall(function()
--                         Properties[Member.Name] = {
--                             Value = Instance[Member.Name],
--                             Type = Member.ValueType,
--                         }
--                     end)
--                 end
--             end
--         end
--     end

--     return Properties
-- end

-- https://anaminus.github.io/rbx/json/api/latest.json

local function GetProperties(Instance)
    local Properties = {}
    local PrioritizedProperties = {}

    local function AddProperty(Name, Value, ValueType, TagsR, CategoryR)
        local lowerName = Name:lower()

        local PrioritizedProperty = PrioritizedProperties[lowerName]

        if PrioritizedProperty then
            if PrioritizedProperty.Name ~= Name then
                return
            end
        else
            PrioritizedProperties[lowerName] = {
                Name = Name,
                Value = Value,
                Type = ValueType,
                Tags = TagsR,
                Category = CategoryR
            }
        end

        Properties[Name] = {
            Value = Value,
            Type = ValueType,
            Tags = TagsR,
            Category = CategoryR
        }
    end

    local function AddPropertiesFromClass(Class)
        for _, Member in next, Class.Members do
            if Member.MemberType == "Property" then
                pcall(function()
                    AddProperty(
                        Member.Name,
                        Instance[Member.Name],
                        Member.ValueType,
                        Member.Tags,
                        Member.Category
                    )
                end)
            end
        end

        if Class.Superclass then
            local Superclass

            for _, SuperclassData in next, APIDump.Classes do
                if SuperclassData.Name == Class.Superclass then
                    Superclass = SuperclassData
                end
            end

            if Superclass then
                AddPropertiesFromClass(Superclass)
            end
        end
    end

    local InstanceClass

    for _, Class in next, APIDump.Classes do
        if Class.Name == Instance.ClassName then
            InstanceClass = Class
        end
    end

    if InstanceClass then
        AddPropertiesFromClass(InstanceClass)
    end

    return Properties
end

local UIWrapper = Instance.new("ScreenGui")
UIWrapper.Name = "sas-xplorer"; UIWrapper.IgnoreGuiInset = true; UIWrapper.DisplayOrder = 10
UIWrapper.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

do
    local IntroFrame = Instance.new("Frame")
    local UIGradient = Instance.new("UIGradient")
    local Title = Instance.new("TextLabel")
    local UIGradient_2 = Instance.new("UIGradient")
    local IntroFrameTop = Instance.new("Frame")

    IntroFrame.Name = "IntroFrame"
    IntroFrame.Parent = UIWrapper
    IntroFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    IntroFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.Position = UDim2.new(0.25, 0, 0.300000012, 0)
    IntroFrame.Size = UDim2.new(0.5, 0, 0, 0)
    IntroFrame.ZIndex = 0
    IntroFrame.BackgroundTransparency = 1

    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(109, 109, 109))}
    UIGradient.Rotation = -90
    UIGradient.Parent = IntroFrame

    Title.Name = "Title"
    Title.Parent = UIWrapper
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.25, 0, 0.300000012, 0)
    Title.Size = UDim2.new(0.5, 0, 0.400000006, 0)
    Title.Font = Enum.Font.Roboto
    Title.FontFace.Weight = Enum.FontWeight.Thin
    Title.Text = "sasxplorer"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.TextSize = 14.000
    Title.TextWrapped = true
    Title.TextTransparency = 1

    UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(73, 255, 228)), ColorSequenceKeypoint.new(0.63, Color3.fromRGB(93, 19, 135)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(88, 11, 127))}
    UIGradient_2.Rotation = -90
    UIGradient_2.Parent = Title

    IntroFrameTop.Name = "IntroFrameTop"
    IntroFrameTop.Parent = UIWrapper
    IntroFrameTop.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    IntroFrameTop.BorderColor3 = Color3.fromRGB(0, 0, 0)
    IntroFrameTop.BorderSizePixel = 0
    IntroFrameTop.Position = UDim2.new(0.25, 0, 0.299999982, 0)
    IntroFrameTop.Size = UDim2.new(0.5, 0, 0, 0)
    IntroFrameTop.ZIndex = 2

    local IntroFrameTweenIn = TweenService:Create(IntroFrame, TweenInfo.new(0.8, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Size = UDim2.new(0.5, 0, 0.400000006, 0), BackgroundTransparency = 0})
    local TextTweenIn = TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {TextTransparency = 0})

    local IntroFrameTopTweenIn = TweenService:Create(IntroFrameTop, TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {Size = UDim2.new(0.5, 0, 0.400000006, 0)})
    local IntroFrameTopTweenOut = TweenService:Create(IntroFrameTop, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.5, 0, 0, 0)})

    IntroFrameTweenIn:Play()
    task.wait(1)
    TextTweenIn:Play()

    task.wait(1)

    IntroFrameTopTweenIn:Play()
    IntroFrameTopTweenIn.Completed:Wait()
    UIGradient:Destroy()
    UIGradient_2:Destroy()
    Title:Destroy()
    IntroFrame:Destroy()
    task.wait(0.3)
    IntroFrameTopTweenOut:Play()
    IntroFrameTopTweenOut.Completed:Wait()
    IntroFrameTop:Destroy()
end -- Intro

local ExplorerFrame = Instance.new("Frame")
local InstanceExplorer = Instance.new("ScrollingFrame")
local Instance_ = Instance.new("Frame")
local Instance_Wrapper = Instance.new("TextButton")
local ClassIcon = Instance.new("ImageLabel")
local InstanceName = Instance.new("TextLabel")
local Expand = Instance.new("ImageButton")
local SearchBox = Instance.new("TextBox")
local PropertiesTab = Instance.new("Frame")
local PropertyList = Instance.new("ScrollingFrame")

print("Checkpoint 2")

local function RemoveInstance(InstanceUI)
    local OffsetCache = InstanceUI.Position.Y.Offset
    for _, UIInstance in next, InstanceExplorer:GetChildren() do
        if UIInstance.Position.Y.Offset > OffsetCache then
            UIInstance.Position -= UDim2.fromOffset(0, 25)
        end
    end
end

local function GetIndex(InstanceUI)
    return math.round(InstanceUI.Position.Y.Offset / 25)
end

local function AppendInstance(InstanceUI)
    local Offset = (#InstanceExplorer:GetChildren() - 1) * 25
    InstanceUI.Position = UDim2.new(InstanceUI.Position.X, UDim.new(InstanceUI.Position.Y.Scale, Offset))
end

local function InsertInstanceUI(InstanceUI, Index)

    local Offset = Index * 25

    InstanceUI.Position = UDim2.new(InstanceUI.Position.X, UDim.new(InstanceUI.Position.Y.Scale, Offset))

    for _, UIInstance in next, InstanceExplorer:GetChildren() do
        if UIInstance ~= InstanceUI and UIInstance.Position.Y.Offset >= Offset then
            UIInstance.Position += UDim2.fromOffset(0, 25)
        end
    end

end

do
    ExplorerFrame.Parent = UIWrapper
    ExplorerFrame.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
    ExplorerFrame.BorderSizePixel = 0
    ExplorerFrame.Position = UDim2.new(0.779999971, 0, 0, 0)
    ExplorerFrame.Size = UDim2.new(0.219999999, 0, 1, 0)

    InstanceExplorer.Parent = ExplorerFrame
    InstanceExplorer.Active = true
    InstanceExplorer.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    InstanceExplorer.BorderSizePixel = 0
    InstanceExplorer.Position = UDim2.new(0, 0, 0.0500000007, 0)
    InstanceExplorer.Size = UDim2.new(1, 0, 0.949999988, 0)
    InstanceExplorer.BottomImage = "rbxassetid://13814803784"
    InstanceExplorer.TopImage = "rbxassetid://13814804547"
    InstanceExplorer.ScrollBarThickness = 5

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = ExplorerFrame
    SearchBox.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0, 10, 0, 0)
    SearchBox.Size = UDim2.new(1, -10, 0.0500000007, 0)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderText = "Filter workspace"
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 16.000
    SearchBox.TextStrokeColor3 = Color3.fromRGB(31, 31, 31)
    SearchBox.TextStrokeTransparency = 0.000
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    Instance_Wrapper.Name = "InstanceWapper"
    Instance_Wrapper.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Instance_Wrapper.BackgroundTransparency = 1
    Instance_Wrapper.Size = UDim2.new(1, 0, 0, 25)
    Instance_Wrapper.Text = ""

    Instance_.Parent = Instance_Wrapper
    Instance_.Name = "Instance"
    Instance_.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Instance_.BackgroundTransparency = 1.000
    Instance_.Size = UDim2.new(1, 0, 1, 0)

    ClassIcon.Name = "ClassIcon"
    ClassIcon.Parent = Instance_
    ClassIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ClassIcon.BackgroundTransparency = 1.000
    ClassIcon.BorderSizePixel = 0
    ClassIcon.Position = UDim2.new(0, 27, 0, 2)
    ClassIcon.Size = UDim2.new(0.1, -20, 1, -5)
    ClassIcon.Image = "rbxasset://textures/ClassImages.png"
    ClassIcon.ImageRectOffset = Vector2.new(416, 0)
    ClassIcon.ImageRectSize = Vector2.new(16, 16)

    InstanceName.Name = "InstanceName"
    InstanceName.Parent = Instance_
    InstanceName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InstanceName.BackgroundTransparency = 1.000
    InstanceName.BorderSizePixel = 0
    InstanceName.Position = UDim2.new(0.170000017, -17, 0, 0)
    InstanceName.Size = UDim2.new(0.829999983, 17, 1, 0)
    InstanceName.Font = Enum.Font.SourceSans
    InstanceName.LineHeight = 1.060
    InstanceName.Text = "Instance [You shouldn't be seeing this]"
    InstanceName.TextColor3 = Color3.fromRGB(255, 255, 255)
    InstanceName.TextSize = 16.000
    InstanceName.TextStrokeColor3 = Color3.fromRGB(31, 31, 31)
    InstanceName.TextStrokeTransparency = 0.000
    InstanceName.TextXAlignment = Enum.TextXAlignment.Left

    Expand.Name = "Expand"
    Expand.Parent = Instance_
    Expand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Expand.BackgroundTransparency = 1.000
    Expand.BorderSizePixel = 0
    Expand.Position = UDim2.new(0.015, 0, 0.2, 0)
    Expand.Size = UDim2.new(0.0599999987 / 1.5, 0, 0.69999976 / 1.5, 0)
    Expand.Visible = false
    Expand.Image = "rbxassetid://13815346565"

    PropertiesTab.Name = "PropertiesTab"
    PropertiesTab.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    PropertiesTab.BorderSizePixel = 0
    PropertiesTab.Position = UDim2.new(0.780000001, 0, 0.5, 0)
    PropertiesTab.Size = UDim2.new(0.219999999, 0, 0.5, 0)
    PropertiesTab.Visible = true

    PropertyList.Name = "PropertyList"
    PropertyList.Parent = PropertiesTab
    PropertyList.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    PropertyList.BorderSizePixel = 0
    PropertyList.Position = UDim2.new(0, 0, 0, 30)
    PropertyList.Size = UDim2.new(1, 0, 1, -30)
    PropertyList.BottomImage = "rbxassetid://13814803784"
    PropertyList.TopImage = "rbxassetid://13814804547"
    PropertyList.ScrollBarThickness = 6

    PropertiesTab.Parent = UIWrapper
end -- UI Setup

print("Checkpoint 3")

local PropertyCoroutines = {}

local function PopulateProperties(Object)

    PropertyList:ClearAllChildren()

    for _, PropertyCoroutine in next, PropertyCoroutines do
        coroutine.close(PropertyCoroutine)
    end

    local Success, Properties = pcall(GetProperties, Object)

    if not Success then
        warn("Error occured with GetProperties()")
    end

    local Categories = {}

    for _, propertyData in next, Properties do
        if not table.find(Categories, propertyData.Category) then
            table.insert(Categories, propertyData.Category)
        end
    end

    for _, Category in next, Categories do
        local CategoryWrapper
        Categories[Category] = 
    end

    for propertyName, propertyData in pairs(Properties) do

        local Category = propertyData.Category
        
        local PropertyLayout = Instance.new("UIListLayout")
        PropertyLayout.Parent = PropertyList
        PropertyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PropertyLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local PropertyFrame = Instance.new("Frame")
        PropertyFrame.Name = propertyName
        PropertyFrame.Parent = PropertyList
        PropertyFrame.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
        PropertyFrame.Size = UDim2.new(1, 0, 0, 20)
        PropertyFrame.BorderSizePixel = 0

        local PropertyNameLabel = Instance.new("TextLabel")
        PropertyNameLabel.Name = "PropertyNameLabel"
        PropertyNameLabel.Parent = PropertyFrame
        PropertyNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PropertyNameLabel.BackgroundTransparency = 1.0
        PropertyNameLabel.BorderSizePixel = 1
        PropertyNameLabel.BorderColor3 = Color3.new(0.568627, 0.568627, 0.568627)
        PropertyNameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        PropertyNameLabel.Font = Enum.Font.SourceSans
        PropertyNameLabel.Text = propertyName .. " " .. Category
        PropertyNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PropertyNameLabel.TextSize = 14
        PropertyNameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local PropertyNamePadding = Instance.new("UIPadding", PropertyNameLabel)
        PropertyNamePadding.PaddingLeft = UDim.new(0.06,0)

        local PropertyValueLabel = Instance.new("TextLabel")
        PropertyValueLabel.Name = "PropertyValueLabel"
        PropertyValueLabel.Parent = PropertyFrame
        PropertyValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PropertyValueLabel.BackgroundTransparency = 0.9
        PropertyValueLabel.BorderSizePixel = 1
        PropertyValueLabel.BorderColor3 = Color3.new(0.568627, 0.568627, 0.568627)
        PropertyValueLabel.Position = UDim2.new(0.4, 0, 0, 0)
        PropertyValueLabel.Size = UDim2.new(0.6, 0, 1, 0)
        PropertyValueLabel.Font = Enum.Font.SourceSans
        PropertyValueLabel.Text = tostring(propertyData.Value)
        
        if propertyData.Tags and table.find(propertyData.Tags, "ReadOnly") then
            PropertyValueLabel.TextColor3 = Color3.fromRGB(129, 129, 129)
        else
            PropertyValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        PropertyValueLabel.TextSize = 14
        PropertyValueLabel.TextXAlignment = Enum.TextXAlignment.Left

        local PropertyValuePadding = Instance.new("UIPadding", PropertyValueLabel)
        PropertyValuePadding.PaddingLeft = UDim.new(0.03,0)

        local PropertyCoroutine = coroutine.create(function()
            while Object and PropertyLayout.Parent == PropertyList do
                task.wait(1)
                pcall(function()
                    PropertyValueLabel.Text = tostring(Object[propertyName])
                end)
            end
        end)

        coroutine.resume(PropertyCoroutine)

        table.insert(PropertyCoroutines, PropertyCoroutine)
    end
end

local function InstanceClicked(InstanceUIItem, Instance)
    PopulateProperties(Instance)
end

local InstanceUIItem = Instance_Wrapper:Clone()

local function InsertInstance(Object, ParentReference)

    local CurrentSelf

    local function CreateSelf()

        if CurrentSelf then
            RemoveInstance(CurrentSelf)
            CurrentSelf:Destroy()
        end

        local UIItem = InstanceUIItem:Clone()
        CurrentSelf = UIItem

        local InstanceReference = Instance.new("ObjectValue", UIItem)
        InstanceReference.Value = Object

        UIItem.Instance.Expand:SetAttribute("Open", false)

        UIItem.Activated:Connect(function()
            InstanceClicked(UIItem.Instance, Object)
        end)

        UIItem.Instance.InstanceName.Text = Object.Name
        SetClassIcon(UIItem.Instance.ClassIcon, Object.ClassName)

        local Children = Object:GetChildren()

        UIItem.Parent = InstanceExplorer

        if ParentReference then
            UIItem.Instance.Position = ParentReference.Instance.Position + UDim2.new(0.05,0,0,0)
            InsertInstanceUI(UIItem, GetIndex(ParentReference) + 1)
        else
            AppendInstance(UIItem)
        end

        if #Children > 0 then
            UIItem.Instance.Expand.Visible = true
            
            for _, Child in next, Children do
                InsertInstance(Child, UIItem)
            end

            UIItem.Instance.Expand.Activated:Connect(function()

                UIItem.Instance.Expand:SetAttribute("Open", not UIItem.Instance.Expand:GetAttribute("Open"))

                if UIItem.Instance.Expand:GetAttribute("Open") == true then
                    UIItem.Instance.Expand.Rotation = 90
                else
                    UIItem.Instance.Expand.Rotation = 0
                end

            end)
        end
    end

    if ParentReference then
        local OpenedConnection = ParentReference.Instance.Expand:GetAttributeChangedSignal("Open"):Connect(function()
            if ParentReference.Instance.Expand:GetAttribute("Open") == true then
                CreateSelf()
            else
                if CurrentSelf then
                    RemoveInstance(CurrentSelf)
                    wait()
                    CurrentSelf:Destroy()
                end
                CurrentSelf = nil
            end
        end)
        Object.Destroying:Once(function()
            OpenedConnection:Disconnect()
            RemoveInstance(CurrentSelf)
            wait()
            CurrentSelf:Destroy()
        end)
    else
        CreateSelf()
    end
end

do

    local PriorityInstances = {
        workspace,
        game:GetService("Players"),
        game.CoreGui,
        game:GetService("Lighting"),
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer"),
        game:GetService("StarterPack"),
        game:GetService("Teams")
    }

    for _, Instance__ in next, PriorityInstances do
        InsertInstance(Instance__)
    end

    for _, Instance__ in next, game:GetChildren() do
        if not table.find(PriorityInstances, Instance__) then
            InsertInstance(Instance__)
        end
    end
end -- populate instances and their UI elements

print("Checkpoint 4")

delay(30, function() UIWrapper:Destroy() end)
