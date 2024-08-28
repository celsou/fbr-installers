// FBR Windows installer
// Custom page: select path to a Java Virtual Machine (JRE/JDK)

[Code]
function CreateJavaSelectPage(PreviousPageID: Integer): TInputDirWizardPage;
var
  Page: TInputDirWizardPage;
begin
  Page := CreateInputDirPage(PreviousPageID,
    CustomMessage('java_select_caption'),
    CustomMessage('java_select_description'),
    CustomMessage('java_select_text'),
    False, '');
  
  Page.Add('');
  
  Result := Page;  
end;

// Get java.exe path
function GetJavaPath(AParam: String): String;
begin
  if Length(JavaPath) = 0 then
    Result := FindJavaVersion(8, ExpandConstant('{tmp}'))
  else
    Result := JavaPath;
end;