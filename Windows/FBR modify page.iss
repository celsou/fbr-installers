// FBR Windows installer
// Custom page: modify/uninstall page

[Code]
function CreateModifyPage(PreviousPageID: Integer): TWizardPage;
var
  Page: TWizardPage;
  InstallBitmapImage: TBitmapImage;
  RemoveBitmapImage: TBitmapImage;
  ModifyDescripton: TNewStaticText;
  InstallRadioButton: TRadioButton;
  RemoveRadioButton: TRadioButton;
  RemoveCaptionText: TNewStaticText;
  InstallCaptionText: TNewStaticText;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('{cm:version_management_caption}'),
    ExpandConstant('{cm:version_management_description}')
  );

// InstallBitmapImage
  InstallBitmapImage := TBitmapImage.Create(Page);
  with InstallBitmapImage do
  begin    
    Parent := Page.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\adicionar.bmp'));
    Left := ScaleX(0);
    Top := ScaleY(40);
    Width := ScaleX(64);
    Height := ScaleY(64);
    ReplaceColor := $F0F0F0;
    ReplaceWithColor := Page.Surface.Color;
  end;
  
  // RemoveBitmapImage
  RemoveBitmapImage := TBitmapImage.Create(Page);
  with RemoveBitmapImage do
  begin
    Parent := Page.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\remover.bmp'));
    Left := ScaleX(0);
    Top := ScaleY(128);
    Width := ScaleX(64);
    Height := ScaleY(64);
    ReplaceColor := $F0F0F0;
    ReplaceWithColor := Page.Surface.Color;
  end;
  
  // ModifyDescripton
  ModifyDescripton := TNewStaticText.Create(Page);
  with ModifyDescripton do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:modify_description}');
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(413);
    Height := ScaleY(29);
    Align := alTop;
    Font.Height := ScaleY(-12);
    Font.Name := 'Tahoma';
    Font.Style := [fsBold];
    TabOrder := 0;
    WordWrap := True;
  end;
  
  // InstallRadioButton
  InstallRadioButton := TRadioButton.Create(Page);
  with InstallRadioButton do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:install_button_label}');
    Left := ScaleX(72);
    Top := ScaleY(48);
    Name := 'InstallButton';
    Width := ScaleX(281);
    Height := ScaleY(17);
    Checked := True;
    Font.Height := ScaleY(-12);
    Font.Name := 'Tahoma';
    Font.Style := [fsBold];
    TabOrder := 1;
    TabStop := True;
  end;
  
  // Assign install button state to a global variable
  ModifyPage_InstallButton := InstallRadioButton;
  
  // RemoveRadioButton
  RemoveRadioButton := TRadioButton.Create(Page);
  with RemoveRadioButton do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:remove_button_label}');
    Left := ScaleX(72);
    Top := ScaleY(136);
    Width := ScaleX(281);
    Height := ScaleY(17);
    Font.Height := ScaleY(-12);
    Font.Name := 'Tahoma';
    Font.Style := [fsBold];
    TabOrder := 2;
  end;
  
  // InstallCaptionText
  InstallCaptionText := TNewStaticText.Create(Page);
  with InstallCaptionText do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:install_fbr_text}');
    Left := ScaleX(72);
    Top := ScaleY(72);
    Width := ScaleX(330);
    Height := ScaleY(40);   
    AutoSize := False;
    TabOrder := 4;
    WordWrap := True;
  end;
  
  // RemoveCaptionText
  RemoveCaptionText := TNewStaticText.Create(Page);
  with RemoveCaptionText do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:remove_fbr_text}');
    Left := ScaleX(72);
    Top := ScaleY(160);
    Width := ScaleX(330);
    Height := ScaleY(40);
    TabOrder := 3;
    WordWrap := True;
  end;
  
  Result := Page;
end;


// Verifies if there is another FBR versions installed
function IsAlreadyInstalled(): Boolean;
begin  
  
  if FileExists(InstallationPath + '\fuscabr\conf\version.ini') or
     FileExists(InstallationPath + '\fuscabr.js') or
     DirExists(InstallationPath + '\fuscabr') then
    Result := True
  else
    Result := False;
end;

// Verifies if user selected "Uninstall FBR" option
function IsUninstallSelected(): Boolean;
var
  InstallButton: TRadioButton;
begin
  Result := not ModifyPage_InstallButton.Checked;  
end;