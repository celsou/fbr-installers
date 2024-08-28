// Celso Automação - Common Files
// Tools for find a compatible Java Virtual Machine

[Code]
// Test Java executable version by executing a testing class
function TestJavaVersion(JVMPath: String; Version: Integer; TesterPath: String): String;
var
  ErrorCode: Integer;
  Params: String;
begin
  Result := '';
  Params:= 'JavaVersion ' + IntToStr(Version);
  
  if not WildCardMatch(LowerCase(JVMPath), '*\bin\java.exe') then
    JVMPath := JVMPath + '\bin\java.exe';
  
  Exec(JVMPath, Params, TesterPath, 0, ewWaitUntilTerminated, ErrorCode);
  Log('Tested JVM path: ' + JVMPath + ' with error code ' + IntToStr(ErrorCode));
  
  if ErrorCode = 0 then
    Result := JVMPath;
end;


// Look for a compatible JVM version in Windows Registry keys
function SearchJavaRegKeys(Version: Integer; TesterPath: String): String;
var
  RegKey: String;  
  JavaPath: String;
  Concat: String;
  i: Integer;
begin
  JavaPath := '';
  Result := '';  
  
  if RegKeyExists(HKEY_LOCAL_MACHINE, RegKey) then
  begin            
    // Until Java 8
    RegKey := 'SOFTWARE\JavaSoft\Java Runtime Environment';
    for i := Version to 8 do
    begin
      Concat :=  RegKey + '\1.' + IntToStr(i);
      RegQueryStringValue(HKEY_LOCAL_MACHINE, Concat, 'JavaHome', JavaPath);

      if (JavaPath <> '') then
        JavaPath := TestJavaVersion(JavaPath, Version, TesterPath);
      
      if (JavaPath <> '') then
      begin
        Result := JavaPath;
        Exit;
      end;
    end;    
    // Java 9 and upon
    RegKey := 'SOFTWARE\JavaSoft\JRE';
    for i := 9 to Version+20 do
    begin
      Concat :=  RegKey + '\' + IntToStr(i);      
      RegQueryStringValue(HKEY_LOCAL_MACHINE, Concat, 'JavaHome', JavaPath);
      
      if (JavaPath <> '') then
        JavaPath := TestJavaVersion(JavaPath, Version, TesterPath);
      
      if (JavaPath <> '') then
      begin
        Result := JavaPath;
        Exit;
      end;
    end;  
  end;  
end;

// Look for a compatible JVM version at Program Files folder
function SearchJavaFiles(Version: Integer; TesterPath: String): String;
var
  SearchPath: TStringList;
  JavaPath: String;
  FindRec: TFindRec;
  Concat: String;
  i: Integer;
  l: Integer;
begin
  JavaPath := '';
  SearchPath := TStringList.Create();
  // JVM Vendor preferences:
  // 1. Microsoft (OpenJDK)
  // 2. Eclipse (Temurin/AdoptOpenJDK)
  // 3. Oracle (Java)
  SearchPath.add(ExpandConstant('{commonpf}\Microsoft'));
  SearchPath.add(ExpandConstant('{commonpf}\Eclipse Adoptium'));
  SearchPath.add(ExpandConstant('{commonpf}\AdoptOpenJDK'));
  SearchPath.add(ExpandConstant('{commonpf}\Java'));
  SearchPath.add(ExpandConstant('{commonpf32}\Microsoft'));
  SearchPath.add(ExpandConstant('{commonpf32}\Eclipse Adoptium'));  
  SearchPath.add(ExpandConstant('{commonpf32}\AdoptOpenJDK'));
  SearchPath.add(ExpandConstant('{commonpf32}\Java'));
  
  l := SearchPath.Count - 1;
  for i := 0 to l do
  begin    
    if DirExists(SearchPath[i]) and
       (FindFirst(SearchPath[i] + '\jre*', FindRec) or
        FindFirst(SearchPath[i] + '\jdk*', FindRec)) then
    begin
      try
        repeat          
          Concat := SearchPath[i] + '\' + FindRec.Name + '\bin\java.exe';
          
          if FileExists(Concat) then
          begin
            JavaPath := TestJavaVersion(Concat, Version, TesterPath);
            
            if JavaPath <> '' then
            begin
              FindClose(FindRec);
              Result := JavaPath;
              Exit;
            end;
          end;
          
        until not FindNext(FindRec);
      finally
        FindClose(FindRec);
      end;
    end;
        
  end;
    
  Result := JavaPath;
end;

// Search for a specified JVM version, in PATH, Registry and Filesystem
function FindJavaVersion(Version: Integer; TesterPath: String): String;
var  
  JavaPath: String;
  EnvPath: String;
  i: Integer;
begin  
  JavaPath := '';
  
  // First search in PATH environmental variable
  EnvPath := FileSearch('java.exe', GetEnv('PATH'));
  if Length(EnvPath) > 0 then
    JavaPath := TestJavaVersion(EnvPath, Version, TesterPath);
  
  // So, search in Registry
  if JavaPath = '' then
    JavaPath := SearchJavaRegKeys(Version, TesterPath);
  
  // Finally, search in filesystem
  if JavaPath = '' then
    JavaPath := SearchJavaFiles(Version, TesterPath);
  
  Result := JavaPath;
end;