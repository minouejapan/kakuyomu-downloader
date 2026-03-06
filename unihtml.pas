unit UniHtml;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, SysUtils,
  {$IFDEF WINDOWS}
  Windows, WinINet;
  {$ELSE}
  fphttpclient, openssl, opensslsockets;
  {$ENDIF}

const
  UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

function GetHTML(const AURL: string; const CookieName: string = ''; const CookieData: string = ''): string;

implementation

{$IFDEF WINDOWS}
// WinINetを用いたHTMLファイルのダウンロード
function GetHTML(const AURL: string; const CookieName: string = ''; const CookieData: string = ''): string;
var
  hSession    : HINTERNET;
  hService    : HINTERNET;
  dwBytesRead : DWORD;
  dwFlag      : DWORD;
  lpBuffer    : PChar;
  RBuff       : TMemoryStream;
  TBuff       : TStringList;
begin
  Result   := '';
  if (CookieName <> '') and (CookieData <> '') then
{$IFDEF FPC}
    InternetSetCookie(PAnsiChar(AURL), PAnsiChar(CookieName), PAnsiChar(CookieData));
{$ELSE}
    InternetSetCookieW(PWideChar(AURL), PWideChar(CookieName), PWideChar(CookieData));
{$ENDIF}
  hSession := InternetOpen(PChar(UA), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    InternetSetOption(hSession, INTERNET_OPTION_USER_AGENT, PChar(ua), Length(ua));
    dwFlag   := INTERNET_FLAG_RELOAD;
    hService := InternetOpenUrl(hSession, PChar(AURL), nil, 0, dwFlag, 0);
    if Assigned(hService ) then
    begin
      RBuff := TMemoryStream.Create;
      try
        lpBuffer := AllocMem(65536);
        try
          dwBytesRead := 65535;
          while True do
          begin
            if InternetReadFile(hService, lpBuffer, 65535,{SizeOf(lpBuffer),}dwBytesRead) then
            begin
              if dwBytesRead = 0 then
                break;
              RBuff.WriteBuffer(lpBuffer^, dwBytesRead);
            end else
              break;
          end;
        finally
          FreeMem(lpBuffer);
        end;
        TBuff := TStringList.Create;
        try
          RBuff.Position := 0;
          TBuff.LoadFromStream(RBuff, TEncoding.UTF8);
          Result := TBuff.Text;
        finally
          TBuff.Free;
        end;
      finally
        RBuff.Free;
      end;
    end;
    InternetCloseHandle(hService);
  end;
end;
{$ELSE}
function GetHTML(const AURL: string; const CookieName: string = ''; const CookieData: string = ''): string;
var
  Client: TFPHttpClient;

begin
  Result := '';
  InitSSLInterface;

  Client := TFPHttpClient.Create(nil);
  try
    if (CookieName <> '') and (CookieData <> '') then
      Client.Cookies.Add(CookieName + '=' + CookieData);
    Client.AddHeader('User-Agent', UA);
    Client.AllowRedirect := true;
    Result := Client.Get(AURL);
  finally
    Client.Free;
  end;
end;
{$ENDIF}

end.

