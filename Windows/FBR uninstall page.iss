// FBR Windows installer
// Custom page: enable Scada-LTS installation mode

[Code]
function CreateUninstallPage(): TOutputProgressWizardPage;
var
  Page: TOutputProgressWizardPage;  
begin
  Page := CreateOutputProgressPage(CustomMessage('uninstaller_caption'),
                                   CustomMessage('uninstaller_description'));
  
  Page.SetText(CustomMessage('uninstalling_fbr'), '');  
  Result := Page;
end;



// Exit from installer wizard without user interaction
procedure Exterminate();
begin
  ForceClose:= True;
  WizardForm.Close;  
end;



procedure UninstallFBR(Page: TOutputProgressWizardPage);
var  
  i: Integer;
  Command: String;
  Params: String;  
  Tmp: String; 
  VerifySuccess: Integer;
  ErrorCode: Integer; 
begin  
  if (MsgBox(CustomMessage('confirm_uninstall'), mbConfirmation, MB_YESNO) = IDNO) then  
    Exit;

  // Show Uninstall progress page
  Page.SetProgress(10, 1000);
  Page.Show();
  Page.SetProgress(100, 1000);
  Sleep(10);
  
  // ============= UNINSTALL TASKS =============  
  VerifySuccess := 0;
  Tmp := ExpandConstant('{tmp}');
  
  // Delete Files
  if not DelTree(ExpandConstant('{code:GetInstallationPath}\fuscabr'), True, True, True) or
         DeleteFile(ExpandConstant('{code:GetInstallationPath}\fuscabr.js')) then
    VerifySuccess := VerifySuccess + 1;
  
  Page.SetProgress(600, 1000);

  // Unregister from page.tag
  Command := GetJavaPath('');
  Params := 'RegexEditor '+
            ExpandConstant('"{code:GetInstallationPath}\..\WEB-INF\tags\page.tag" ') +
            '"< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>" ' + 
            ' ""';
  Log('Running command: ' + Command + ' ' + Params);        
  ExecAndLogOutput(Command, Params, Tmp, SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode, nil);
  VerifySuccess := VerifySuccess + ErrorCode;    
  Page.SetProgress(750, 1000);
  
  // Unregister from publicView.jsp
  Command := GetJavaPath('');
  Params := 'RegexEditor '+
            ExpandConstant('"{code:GetInstallationPath}\..\WEB-INF\jsp\publicView.jsp" ') +
            '"< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>" ' + 
            ' ""';
  Log('Running command: ' + Command + ' ' + Params);          
  ExecAndLogOutput(Command, Params, Tmp, SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode, nil);
  VerifySuccess := VerifySuccess + ErrorCode;    
  Page.SetProgress(990, 1000);  
  // ========== UNINSTALL TASKS (END) ==========
  
  Log('Sum of error codes: ' + IntToStr(VerifySuccess));
  
  Page.SetProgress(1000, 1000);
  Sleep(1000);
  MsgBox(CustomMessage('uninstall_complete'), mbInformation, MB_OK);
  
  Page.Hide();
  Exterminate();
end;