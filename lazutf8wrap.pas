//
// DelphiとLazarusで文字列操作手続き・関数を共通化するためのラッパー
//
// Delphiでビルドする際に使用する
//
unit LazUTF8wrap;

interface

uses
  System.Classes, System.SysUtils;

// const宣言でエイリアス定義できないものはインライン化する
function UTF8Length(S: string): Integer;
function UTF8Copy(S: string; Index: Integer; Count: Integer): string;
procedure UTF8Insert(Substr: String; var Dest: String; Index: Integer);
procedure UTF8Delete(var S: String; Index: Integer; Count: Integer);

// エイリアス
const
  UTF8Pos: function(const SubStr, Str: string): Integer = System.Pos;
  UTF8StringReplace: function(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string = System.SysUtils.StringReplace;


implementation

function UTF8Length(S: string): Integer; inline;
begin
  Result := Length(S);
end;

function UTF8Copy(S: string; Index: Integer; Count: Integer): string; inline;
begin
  Result := Copy(S, Index, Count);
end;

procedure UTF8Insert(Substr: String; var Dest: String; Index: Integer); inline;
begin
  Insert(SubStr, Dest, Index);
end;

procedure UTF8Delete(var S: String; Index: Integer; Count: Integer); inline;
begin
  Delete(S, Index, Count);
end;

end.

