// FBR Windows installer

#define MyAppName "FBR"
#define MyAppVersion "2.1.1"
#define MyAppURL "https://celsoautomacao.com.br"
#define MyAppFolder "Z:\Windows"
#define FBRVersionReference "2.11"

[Setup]
// Info
AppId={{5CB6C78A-8771-4942-82C2-394DD5E2A42C}
AppName={#MyAppName}
AppVerName={#MyAppName} {#MyAppVersion}
AppVersion={#MyAppVersion}
AppComments=FBR is a general purpose library to improve ScadaBR/Scada-LTS
AppPublisherURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
LicenseFile={#MyAppFolder}\fuscabr\LICENSE.txt

// Installer settings
AppendDefaultDirName=no
DefaultDirName={commonpf}\ScadaBR
DefaultGroupName={#MyAppName}
Compression=lzma
OutputDir={#MyAppFolder}\bin
OutputBaseFilename={#MyAppName}_{#MyAppVersion}_setup
ArchitecturesInstallIn64BitMode=x64compatible
SolidCompression=yes
Uninstallable=no

// Appearance
SetupIconFile={#MyAppFolder}\images\SETUP.ico
DirExistsWarning=no
DisableWelcomePage=no
WizardImageFile=images\banner_big.bmp,images\banner_small.bmp
WizardSmallImageFile=images\small_icon.bmp



[Files]
Source: "images\adicionar.bmp"; DestDir: "{tmp}"; Flags: ignoreversion dontcopy
Source: "images\remover.bmp"; DestDir: "{tmp}"; Flags: ignoreversion dontcopy
Source: "fuscabr\*"; DestDir: "{code:GetInstallationPath}\fuscabr"; Flags: ignoreversion overwritereadonly createallsubdirs recursesubdirs
Source: "java_tools\*"; DestDir: "{tmp}"; Flags: ignoreversion createallsubdirs recursesubdirs dontcopy



// Custom Messages
#include "FBR languages.iss"



[Run]
// Configure FBR language
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\fuscabr\conf\common.json"" ""/conf/i18n/..\.json"" ""/conf/i18n/pt.json"" "; WorkingDir: "{tmp}"; Flags: runhidden; Check: IsSelectedLanguage('brazilianportuguese');
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\fuscabr\conf\common.json"" ""/conf/i18n/..\.json"" ""/conf/i18n/en.json"" "; WorkingDir: "{tmp}"; Flags: runhidden; Check: IsSelectedLanguage('english');
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\fuscabr\conf\common.json"" ""/conf/i18n/..\.json"" ""/conf/i18n/es.json"" "; WorkingDir: "{tmp}"; Flags: runhidden; Check: IsSelectedLanguage('spanish');
// Register FBR in JSP files
  // Delete old entries (if exists)
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\..\WEB-INF\tags\page.tag"" ""< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>"" "" "" "; WorkingDir: "{tmp}"; Flags: runhidden;
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\..\WEB-INF\jsp\publicView.jsp"" ""< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>"" "" "" "; WorkingDir: "{tmp}"; Flags: runhidden;
  // Create new entries
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\..\WEB-INF\tags\page.tag"" ""</\s*head\s*>"" ""<script src=""""resources/fuscabr/fuscabr.js"""" defer></script>&#13;</head>"" "; WorkingDir: "{tmp}"; Flags: runhidden;
Filename: "{code:GetJavaPath}"; Parameters: "RegexEditor ""{code:GetInstallationPath}\..\WEB-INF\jsp\publicView.jsp"" ""</\s*head\s*>"" ""<script src=""""resources/fuscabr/fuscabr.js"""" defer></script>&#13;</head>"" "; WorkingDir: "{tmp}"; Flags: runhidden;
// Map file extensions to "default" Tomcat's servlet (Scada-LTS only)
Filename: "{code:GetJavaPath}"; Parameters: "MapToDefaultServlet ""{code:GetInstallationPath}\..\WEB-INF\web.xml"" ""*.css;*.html;*.js;*.json"" "; WorkingDir: "{tmp}"; Flags: runhidden; Check: InstallForLTS();



[InstallDelete]
Type: files; Name: "{code:GetInstallationPath}\fuscabr.js"



[Code]
// Global variables
var
  ForceClose: Boolean;
  JavaPath: String;
  InstallationPath: String;
  SelectJavaPage: TInputDirWizardPage;
  ModifyPage: TWizardPage;
  ModifyPage_InstallButton: TRadioButton;
  UninstallPage: TOutputProgressWizardPage;
  ConfirmLTSPage: TOutputMsgWizardPage;
  ConfirmLTSPage_ConfirmBox: TCheckbox;

// Import custom pages and scripts
#include "JavaFinder.iss"
#include "FBR modify page.iss"
#include "FBR select java page.iss"
#include "FBR Scada-LTS page.iss"
#include "FBR uninstall page.iss"

  
// Verify what language are being used in installer
function IsSelectedLanguage(AParam: String): Boolean;
begin
  Result := False;  
  if SameText(ActiveLanguage(), AParam) then
    Result := True;
end;


// Verifies if the path of ScadaBR/Scada-LTS entered by user is valid,
// and defines the path to FBR installation
function ValidateInstallationPath(): Boolean;
var
  SearchPath: String;
  InstallPath: String;
begin
  Result := False;
  
  SearchPath := ExpandConstant('{app}\tomcat\webapps\ScadaBR\resources;') + 
                ExpandConstant('{app}\webapps\ScadaBR\resources;') +
                ExpandConstant('{app}\tomcat\webapps\Scada-LTS\resources;') + 
                ExpandConstant('{app}\webapps\Scada-LTS\resources;') +
                ExpandConstant('{app}\..\..\resources;') +
                ExpandConstant('{app}\..\resources;') +
                ExpandConstant('{app}\resources;');
                
  InstallPath := FileSearch('common.js', SearchPath);
  StringChangeEx(InstallPath, '\common.js', '', True);

  if Length(InstallPath) > 0 then
  begin
    InstallationPath := InstallPath;
    Result := True;
  end;
end;


// Get the path to FBR installation
function GetInstallationPath(AParam: String): String;
begin
  Result := InstallationPath;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm:= not ForceClose;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  // Validate installation path
  if (CurPageID = wpSelectDir) then
  begin        
    Result := ValidateInstallationPath();
    if not Result then  
      MsgBox(CustomMessage('invalid_scadabr_path'), mbError, MB_OK);    
  end
  // Validate Java executable path (only if not auto detected)
  else if (CurPageID = SelectJavaPage.ID) then
  begin    
    JavaPath := TestJavaVersion(SelectJavaPage.Values[0], 8, ExpandConstant('{tmp}'));
    if (JavaPath = '') then
    begin
      MsgBox(CustomMessage('invalid_java_path'), mbError, MB_OK);
      Result := False;
    end;
  end
  // Verify if user wants to uninstall the library
  else if (CurPageID = ModifyPage.ID) and IsUninstallSelected() then
  begin
    UninstallFBR(UninstallPage);
    Result := False;
  end;
end;


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  
  if (PageID = ModifyPage.ID) and not IsAlreadyInstalled() then
    Result := True
  else if (PageID = SelectJavaPage.ID) and (GetJavaPath('') <> '') then
    Result := True
  else if (PageID = ConfirmLTSPage.ID) and not IsScadaLTS() then
    Result := True;
end;


procedure InitializeWizard();
var
  AfterID: Integer;
begin  
  // Extract all java tools
  ExtractTemporaryFiles('{tmp}\*.class');
  // Extract all bitmap icons
  ExtractTemporaryFiles('{tmp}\*.bmp');    
  // Find a compatible JVM
  JavaPath := GetJavaPath('');
  
  // Pages configuration
  SelectJavaPage := CreateJavaSelectPage(wpSelectDir);
  ModifyPage := CreateModifyPage(SelectJavaPage.ID);  
  ConfirmLTSPage := CreateConfirmLTSPage(ModifyPage.ID);
  UninstallPage := CreateUninstallPage();
end;

