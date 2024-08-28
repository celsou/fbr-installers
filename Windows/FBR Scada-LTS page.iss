// FBR Windows installer
// Custom page: enable Scada-LTS installation mode

[Code]
function CreateConfirmLTSPage(PreviousPageID: Integer): TOutputMsgWizardPage;
var
  Page: TOutputMsgWizardPage;
  ConfirmLTSButton: TCheckBox;
begin
  
  Page := CreateOutputMsgPage(PreviousPageID,
          CustomMessage('scadalts_mode_caption'),
          CustomMessage('scadalts_mode_description'),
          CustomMessage('scadalts_mode_text'));  
  
  Page.MsgLabel.Font.Height := ScaleY(-12);
  Page.MsgLabel.Height := 50;
  
  // ConfirmLTSButton
  ConfirmLTSButton := TCheckBox.Create(Page);
  with ConfirmLTSButton do
  begin
    Parent := Page.Surface;
    Caption := CustomMessage('install_for_scadalts');
    Name := 'ConfirmLTSButton';
    Left := ScaleX(0);
    Top := ScaleY(46);
    Width := ScaleX(300);
    Height := ScaleY(17);
    Checked := True;
    Font.Height := ScaleY(-13);
    Font.Name := 'Tahoma';
    State := cbChecked;
    TabOrder := 0;
  end;

  // Assign Button state to global variable
  ConfirmLTSPage_ConfirmBox := ConfirmLTSButton;
  
  Result := Page;
end;


function IsScadaLTS(): Boolean;
var
  IP: String;
  SearchPath: TStringList;
  LTSFeaturesCount: Integer;
  i: Integer;
  l: Integer;
  MinFeaturesNeeded: Integer;
begin
  MinFeaturesNeeded := 3;
  LTSFeaturesCount := 0;
  IP := InstallationPath;
  
  // Look for Scada-LTS unique files and folders
  SearchPath := TStringList.Create();  
  SearchPath.add(IP + '\vue-components');
  SearchPath.add(IP + '\common_deprecated.css');
  SearchPath.add(IP + '\..\WEB-INF\classes\org\scada_lts');
  SearchPath.add(IP + '\..\WEB-INF\jsp\app.jsp');
  SearchPath.add(IP + '\..\WEB-INF\jsp\watchListModern.jsp');
  
  l := SearchPath.Count - 1;
  for i := 0 to l do
  begin    
    if FileOrDirExists(SearchPath[i]) then
       LTSFeaturesCount := LTSFeaturesCount + 1;     
  end;  
  
  // Return if it is ScadaBR or Scada-LTS
  if (LTSFeaturesCount > MinFeaturesNeeded) then
    // System is Scada-LTS
    Result := True
  else
    // System is ScadaBR
    Result := False;
end;

// Run installation for Scada-LTS?
function InstallForLTS(): Boolean;
begin
  if not IsScadaLTS() then
    Result := False
  else
    Result := ConfirmLTSPage_ConfirmBox.Checked;
end;