; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "HerderCPUSim"
#define MyAppVersion "0.2-beta.1"
#define MyAppPublisher "Herder-Gymnasium LK Inf-4 2015"
#define MyAppURL "https://github.com/HERDER2014/CPUSim"
#define MyAppExeName "bin\cpusim.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{B4370425-37F8-41F6-A4BD-CA822E2D6B5E}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=.\LICENSE
OutputDir=.\Output
OutputBaseFilename=HerderCPUSim-0.2-beta.1
SetupIconFile=.\src\cpusim.ico
Compression=lzma
SolidCompression=yes     
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1
Name: "ASM_Association"; Description: "Associate ""asm"" extension"; GroupDescription: File extensions:


[Files]
Source: ".\bin\cpusim.exe"; DestDir: "{app}\bin\"; Flags: ignoreversion
Source: ".\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\bin\*"; DestDir: "{app}\bin\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: ".\Examples\*"; DestDir: "{app}\Examples\"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Registry]
Root: HKCR; Subkey: ".asm"; ValueType: string; ValueName: ""; ValueData: "HerderCPUSim"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "HerderCPUSim"; ValueType: string; ValueName: ""; ValueData: "Herder CPUSim"; Flags: uninsdeletekey
Root: HKCR; Subkey: "HerderCPUSim\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExeName},0"
Root: HKCR; Subkey: "HerderCPUSim\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExeName}"" ""%1"""
