(*
  カクヨム小説ダウンローダー[kakuyomudl]

  4.0 2024/07/11  Lazarusに移植した上でLazarus/Delphiどちらでもビルド出来るようにした
  3.3 2024/03/18  挿絵画像のURL抽出が不完全だった不具合を修正した
                  本文の最初が挿絵の場合に本文を抽出出来ない不具合を修正した
                  本文中のURLをリンク化する処理を廃止した
                  いくつかの置換処理を正規表現処理に変更した
  3.2 2024/03/09  &#x????;にエンコードされているUnicode文字の一部がデコード出来ずにエラーが発生する不具合を修正した
  3.1 2023/11/30  作品の進捗状況をうまく取得出来ていなかった不具合を修正した
                  ダウンロードを安定させるため各話ページDL毎に0.5秒のインターバルを追加した
  3.0 2023/11/29  作品トップページの構造が大きく変わったことに対応するため修正した
  2.9 2023/07/30  DL開始ページを指定した場合のNaro2mobiに送るDLページ数が1少なかった不具合を修正した
  2.8 2023/07/24  オプション引数確認処理を変更し、DL開始ページ指定オプション-sを追加した
  2.7 2023/06/24  LoadFromHTMLが取得したHTMLを直接返すようにした
  2.6 2023/05/07  作者ページURL取得を追加した
  2.5 2023/03/30  行の先頭に半角空白がある場合は除去する処理を追加した
  2.4 2023/03/19  &#????;の処理を16進数2byte決め打ちから10進数でも変換できるように変更した
  2.3 2023/02/27  &#x????;にエンコードされている‼等のUnicode文字をデコードする処理を追加した
                  識別タグの文字列長さを定数からUTF8Length(識別文字定数)に変更した
  2.2 2022/12/29  見出しの青空文庫タグを変更した
  2.1 2022/10/13  前書きの最後にある"…続きを読む"を削除するようにした
  2.0 2022/08/05  タイトル名の先頭に連載状況（連載中・完結）を追加するようにした
  1.9 2022/03/02  前書きに青空文庫タグがあることがあるため代替文字化処理を追加した
      2021/12/15  GitHubに上げるためソースコードを整理した
  1.8 2021/10/07  エピソードが1話の場合にダウンロード出来なかった不具合を修正した
                  前書きがない場合ダウンロードに失敗する不具合を修正した
  1.7 2021/09/26  表紙画像があればタグを挿入する処理を追
  1.6 2021/09/16  挿絵のタグ処理を追加した
                  ベタURLを［＃リンク］タグ処理するようにした
  1.5 2021/09/02  丸傍点タグの誤記を修正
  1.4 2021/07/28  カクヨムの特殊な傍点タグに対応
  1.3 2021/07/09  前書きを正しく認識できなかった不具合を修正
                  各ページの本文を正しく認識できなかった不具合を修正
                  ※いづれも識別に用いたタグの形式を一種類しかないと決め打ちしていたことが原因
  1.2 2021/07/03  Naro2mobiから起動した際に進捗状況をNaro2mobi側に知らせるようにした
  1.1 2021/07/01  章の認識が不完全だった不具合を修正(chapter level-1とlevel-2があった)
  1.0 2021/06/30  alphadlのソースコードをテンプレートとしてカクヨム用として作成
*)
program kakuyomudl;

{$APPTYPE CONSOLE}

{$IFDEF FPC}
  {$MODE Delphi}
  {$codepage utf8}
{$ENDIF}

{$R *.res}
{$R verinfo.res}

//{$R *.dres}

uses
{$IFDEF FPC}
  SysUtils,
  Classes,
  Messages,
  LazUTF8,
{$ELSE}
  LazUTF8wrap,
  System.SysUtils,
  System.Classes,
  WinAPI.Messages,
{$ENDIF}
  Windows,
  regexpr,
  WinInet;

const
  // データ抽出用の識別タグ
  STITLEB  = '<h1 .*?><.*?><a title="';     // 小説表題
  STITLEE  = '" href=';
  SAUTHERB = '<div class="partialGiftWidgetActivityName"><a href="';   // 作者
  SAUTHERM = '" .*?>';
  SAUTHERE = '</a>';
  SHEADERB = '"introduction":"'; // 前書き
  SHEADERE = '",';
  SSTRURLB = '{"__typename":"Episode","id":"';  // 各話リンクURL
  SSTRURLE = '","title":"';
  SSTTLE   = '",';

  SCAPTB   = '<p class="chapterTitle level1 js-vertical-composition-item"><span>';
  SCAPTB2   = '<p class="chapterTitle level2 js-vertical-composition-item"><span>';
  SCAPTE   = '</span>';
  SEPISB   = '<p class="widget-episodeTitle js-vertical-composition-item">';
  SEPISE   = '</p>';
  SBODYB   = '<p id="p1"';
  SBODYB2   = '<figure id="p1"';
  SBODYM   = '>';
  SBODYE   = '</div>';

  SERRSTR  = '<div class="dots-indicator" id="LoadingEpisode">';
  SPICTB   = '<img src="';
  SPICTM   = '';
  SPICTE   = '" /></figure>';
  SHREFB   = '<a href="';
  SHREFE   = '">';
  SURLB    = 'https://';

  SHEAD    = '<h3 class="heading-level2">目次</h3>';

  // 青空文庫形式
  AO_RBI = '｜';							// ルビのかかり始め(必ずある訳ではない)
  AO_RBL = '《';              // ルビ始め
  AO_RBR = '》';              // ルビ終わり
  AO_TGI = '［＃';            // 青空文庫書式設定開始
  AO_TGO = '］';              //        〃       終了
  AO_CPI = '［＃「';          // 見出しの開始
  AO_CPT = '」は大見出し］';	// 章
  AO_SEC = '」は中見出し］';  // 話
  AO_PRT = '」は小見出し］';

  AO_CPB = '［＃大見出し］';        // 2022/12/28 こちらのタグに変更
  AO_CPE = '［＃大見出し終わり］';
  AO_SEB = '［＃中見出し］';
  AO_SEE = '［＃中見出し終わり］';
  AO_PRB = '［＃小見出し］';
  AO_PRE = '［＃小見出し終わり］';

  AO_DAI = '［＃ここから';		// ブロックの字下げ開始
  AO_DAO = '［＃ここで字下げ終わり］';
  AO_DAN = '字下げ］';
  AO_PGB = '［＃改丁］';			// 改丁と会ページはページ送りなのか見開き分の
  AO_PB2 = '［＃改ページ］';	// 送りかの違いがあるがどちらもページ送りとする
  AO_SM1 = '」に傍点］';			// ルビ傍点
  AO_SM2 = '」に丸傍点］';		// ルビ傍点 どちらもsesami_dotで扱う
  AO_EMB = '［＃丸傍点］';        // 横転開始
  AO_EME = '［＃丸傍点終わり］';  // 傍点終わり
  AO_KKL = '［＃ここから罫囲み］' ;     // 本来は罫囲み範囲の指定だが、前書きや後書き等を
  AO_KKR = '［＃ここで罫囲み終わり］';  // 一段小さい文字で表記するために使用する
  AO_END = '底本：';          // ページフッダ開始（必ずあるとは限らない）
  AO_PIB = '［＃リンクの図（';          // 画像埋め込み
  AO_PIE = '）入る］';        // 画像埋め込み終わり
  AO_LIB = '［＃リンク（';          // 画像埋め込み
  AO_LIE = '）入る］';        // 画像埋め込み終わり
  AO_CVB = '［＃表紙の図（';  // 表紙画像指定
  AO_CVE = '）入る］';        // 終わり

  CRLF   = #$0D#$0A;

// ユーザメッセージID
  WM_DLINFO  = WM_USER + 30;

var
  PageList,
  TextPage,
  LogFile: TStringList;
  TextLine,
  Capter, URL, Path, FileName,
  NvStat, StartPage: string;
  hWnd: THandle;
  CDS: TCopyDataStruct;
  StartN: integer;


// WinINetを用いたHTMLファイルのダウンロード
function LoadFromHTML(URLadr: string): string;
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
  hSession := InternetOpen('WinINet', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(hSession) then
  begin
    dwFlag   := INTERNET_FLAG_RELOAD;
    hService := InternetOpenUrl(hSession, PChar(URLadr), nil, 0, dwFlag, 0);
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

// HTMLテキスト内のCR/LF(#$0D#$0A)を除去する
function ElimCRLF(Base: string): string;
begin
  Result := UTF8StringReplace(Base, #$0D#$0A, '', [rfReplaceAll]);
end;

// 前書き内のタグを削除する（カクヨム限定）
function ElimTag(Base: string): string;
begin
  Base := ReplaceRegExpr('<.*?>', Base, '');

  Result := Base;
end;

// 本文内の余計なタグを削除する（カクヨム限定）
function ElimBodyTag(Base: string): string;
var
  p, i: integer;
  tmplist: TStringList;
  tmp: string;
begin
  Result := '';
  Base := UTF8StringReplace(Base, '</p>', '', [rfReplaceAll]);
  Base := UTF8StringReplace(Base, '</a>', '', [rfReplaceAll]);
  tmplist := TStringList.Create;
  try
    tmplist.Text := Base;
    for i := 0 to tmplist.Count - 1 do
    begin
      if UTF8Pos('class="blank">', tmplist[i]) > 0 then
        tmplist[i] := '';
      tmp := tmplist[i];
      p := UTF8Pos('">', tmp);
      if p > 0 then
      begin
        UTF8Delete(tmp, 1, p + 1);
        // 先頭の半角空白を除去する
        while tmp[1] = ' ' do
          UTF8Delete(tmp, 1, 1);
        tmplist[i] := tmp;
      end;
    end;
  finally
    Result := tmplist.Text;
    tmplist.Free;
  end;
end;

// 指定された文字列の前と後のスペース(' '/'　'/#$20/#$09/#$0D/#$0A)を除去する
// '　　文字　列　　' → '文字　列'
function TrimSpace(Base: string): string;
var
  p: integer;
  c: string;
begin
  while True do
  begin
    if UTF8Length(Base) = 0 then
      Break;
    c := UTF8Copy(Base, 1, 1);
    if UTF8Pos(c, ' 　'#$09#$0D#$0A) > 0 then
      UTF8Delete(Base, 1, 1)
    else
      Break;
  end;
  while True do
  begin
    p := UTF8Length(Base);
    if p = 0 then
      Break;
    c := UTF8Copy(Base, p, 1);
    if UTF8Pos(c, ' 　'#$09#$0D#$0A) > 0 then
      UTF8Delete(Base, p, 1)
    else
      Break;
  end;
  Result := Base;
end;

// 本文の改行タグを改行コードに変換する
function ChangeBRK(Base: string): string;
begin
  Result := UTF8StringReplace(Base, '<br />', #13#10, [rfReplaceAll]);
end;

// 本文の青空文庫ルビ指定に用いられる文字があった場合誤作動しないように青空文庫代替表記に変換する(2022/3/25)
function ChangeAozoraTag(Base: string): string;
var
  tmp: string;
begin
  tmp := UTF8StringReplace(Base, '<rp>《</rp>', '<rp>(</rp>', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rp>》</rp>', '<rp>)</rp>', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp, '《', '※［＃始め二重山括弧、1-1-52］',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '》', '※［＃終わり二重山括弧、1-1-53］',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '｜', '※［＃縦線、1-1-35］',   [rfReplaceAll]);
  Result := tmp;
end;

// 本文のルビタグを青空文庫形式に変換する
function ChangeRuby(Base: string): string;
var
  tmp: string;
begin
  // <rp>タグを除去
  tmp := UTF8StringReplace(Base, '<rp>(</rp>', '', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rp>)</rp>', '', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rp>（</rp>', '', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rp>）</rp>', '', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rb>', '', [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '</rb>', '', [rfReplaceAll]);
  // rubyタグを青空文庫形式に変換
  tmp := UTF8StringReplace(tmp,  '<ruby>', AO_RBI, [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<rt>',   AO_RBL, [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '</rt></ruby>', AO_RBR, [rfReplaceAll]);
  // カクヨムの傍点タグ？
  tmp := UTF8StringReplace(tmp,  '<em class="emphasisDots"><span>', AO_EMB, [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '<span>', AO_EMB,  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '</span></em>', AO_EME,  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '</span>', AO_EME,  [rfReplaceAll]);

  Result := tmp;
end;

// Delphi XE2ではPos関数に検索開始位置を指定出来ないための代替え
function PosN(SubStr, Str: string; StartPos: integer): integer;
var
  tmp: string;
  p: integer;
begin
  tmp := UTF8Copy(Str, StartPos, UTF8Length(Str));
  p := UTF8Pos(SubStr, tmp);
  if p > 0 then
    Result := p + StartPos - 1  // 1ベーススタートのため1を引く
  else
    Result := 0;
end;

// HTML特殊文字の処理
// 1)エスケープ文字列 → 実際の文字
// 2)&#x????; → 通常の文字
function Restore2RealChar(Base: string): string;
var
  tmp, cd: string;
  w: integer;
  ch: Char;
  r: TRegExpr;
begin
  // エスケープされた文字
  tmp := UTF8StringReplace(Base, '&lt;',      '<',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&gt;',      '>',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&quot;',    '"',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&nbsp;',    ' ',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&yen;',     '\',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&brvbar;',  '|',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&copy;',    '©',  [rfReplaceAll]);
  tmp := UTF8StringReplace(tmp,  '&amp;',     '&',  [rfReplaceAll]);
  // &#????;にエンコードされた文字をデコードする(2023/3/19)
  // 正規表現による処理に変更した(2024/3/9)
  r := TRegExpr.Create;
  try
    r.Expression  := '&#.*?;';
    r.InputString := tmp;
    if r.Exec then
    begin
      repeat
        UTF8Delete(tmp, r.MatchPos[0], r.MatchLen[0]);
        cd := r.Match[0];
        UTF8Delete(cd, 1, 2);           // &#を削除する
        UTF8Delete(cd, UTF8Length(cd), 1);  // 最後の;を削除する
        if cd[1] = 'x' then         // 先頭が16進数を表すxであればDelphiの16進数接頭文字$に変更する
          cd[1] := '$';
        try
          w := StrToInt(cd);
          ch := Char(w);
        except
          ch := '？';
        end;
        UTF8Insert(ch, tmp, r.MatchPos[0]);
      until not r.ExecNext;
    end;
  finally
    r.Free;
  end;
  Result := tmp;
end;

// 埋め込まれた画像リンクを青空文庫形式に変換する
// 但し、画像ファイルはダウンロードせずにリンク先をそのまま埋め込む
function ChangeImage(Base: string): string;
begin
  Base := ReplaceRegExpr('<figure id=.*?src="', Base, AO_PIB);
  Base := ReplaceRegExpr('".*?</figure>', Base, AO_PIE);

  Result := Base;
end;

// 本文のリンクタグを除去する
function Delete_href(Base: string): string;
var
  p, p2: integer;
begin
  p := UTF8Pos(SHREFB, Base);
  while p > 0 do
  begin
    p2 := PosN(SHREFE, Base, p);
    if p2 > 1 then
    begin
      UTF8Delete(Base, p, p2 - p + 2);
    end;
    p := UTF8Pos(SHREFB, Base);
  end;
  Result := Base;
end;

// タイトル名をファイル名として使用出来るかどうかチェックし、使用不可文字が
// あれば修正する('-'に置き換える)
// フォルダ名の最後が'.'の場合、フォルダ作成時に"."が無視されてフォルダ名が
// 見つからないことになるため'.'も'-'で置き換える
// LazarusではUTF8文字列をインデックス(string[])でアクセス出来ないため、
// UTF8Copy, UTF8Delete, UTF8Insert処理で置き換える
{$IFDEF FPC}
function PathFilter(PassName: string): string;
var
  i, l: integer;
  path: string;
  tmp: AnsiString;
  ch: string;     // LazarusではCharにUTF-8の文字を代入できないためstringで定義する
begin
  // ファイル名を一旦ShiftJISに変換して再度Unicode化することでShiftJISで使用
  // 出来ない文字を除去する
  tmp := UTF8ToWinCP(PassName);
  path := WinCPToUTF8(tmp);      // これでUTF-8依存文字は??に置き換わる
  l :=  UTF8Length(path);
  for i := 1 to l do
  begin
    ch := UTF8Copy(path, i, 1); // i番目の文字を取り出す
    if Pos(ch, '\/;:*?"<>|. '+#$09) > 0 then // 文字種が使用不可であれば
    begin
      UTF8Delete(path, i, 1);                // 該当文字を削除して
      UTF8Insert('-', path, i);              // 代わりに'-'を挿入する
    end;
  end;
  Result := path;
end;
{$ELSE}
function PathFilter(PassName: string): string;
var
	i, l: integer;
  path: string;
  tmp: AnsiString;
  ch: char;
begin
  // ファイル名を一旦ShiftJISに変換して再度Unicode化することでShiftJISで使用
  // 出来ない文字を除去する
  tmp := AnsiString(PassName);
	path := string(tmp);
  l :=  Length(path);
  for i := 1 to l do
  begin
  	ch := Char(path[i]);
    if Pos(ch, '\/;:*?"<>|. '+#$09) > 0 then
      path[i] := '-';
  end;
  Result := path;
end;
{$ENDIF}

// 小説本文をHTMLから抜き出して整形する
function ParsePage(Page: string): Boolean;
var
  sp, ep: integer;
  capt, subt, body: string;
begin
  Result := False;

  Page := ChangeAozoraTag(Page);  // 最初に青空文庫のルビタグ文字｜《》を変換する

  //Page := ElimCRLF(Page);
  // 章(Chapter)＋話(Episode)構成の場合と話(Episode)だけの場合があるため、まずは章があれば処理して次に話を処理する
  sp := UTF8Pos(SCAPTB, Page);  // 章(Chapter Level-1)をチェック
  if sp > 1 then
  begin
    UTF8Delete(Page, 1, UTF8Length(SCAPTB) + sp - 1);
    ep := UTF8Pos(SCAPTE, Page);
    if ep > 1 then
    begin
      capt := UTF8Copy(Page, 1, ep - 1);
      capt := TrimSpace(capt);
      if Capter = capt then
        capt := ''
      else
        Capter := capt;
      UTF8Delete(Page, 1, UTF8Length(SCAPTE) + ep - 1);
    end;
  end;
  sp := UTF8Pos(SCAPTB2, Page);  // 章(Chapter Level-2)をチェック
  if sp > 1 then
  begin
    UTF8Delete(Page, 1, UTF8Length(SCAPTB) + sp - 1);
    ep := UTF8Pos(SCAPTE, Page);
    if ep > 1 then
    begin
      capt := UTF8Copy(Page, 1, ep - 1);
      capt := TrimSpace(capt);
      capt := Restore2RealChar(capt);
      if Capter = capt then
        capt := ''
      else
        Capter := capt;
      UTF8Delete(Page, 1, UTF8Length(SCAPTE) + ep - 1);
    end;
  end;
  sp := UTF8Pos(SEPISB, Page);  // 話(Episode)をチェック
  if sp > 1 then
  begin
    UTF8Delete(Page, 1, UTF8Length(SEPISB) + sp - 1);
    ep := UTF8Pos(SEPISE, Page);
    if ep > 1 then
    begin
      subt := UTF8Copy(Page, 1, ep - 1);
      subt := TrimSpace(subt);
      subt := Restore2RealChar(subt);
      UTF8Delete(Page, 1, UTF8Length(SEPISE) + ep);
      sp  := UTF8Pos(SBODYB, Page);
      if sp = 0 then
      begin
        sp := UTF8Pos(SBODYB2, Page);
      end;
      if sp > 1 then
      begin
        UTF8Delete(Page, 1, + sp - 1);
        //sp := UTF8Pos(SBODYM, Page);
        //if sp > 0 then
        //  UTF8Delete(Page, 1, sp);
        ep := UTF8Pos(SBODYE, Page);
        if ep > 1 then
        begin
          body := UTF8Copy(Page, 1, ep - 1);
          body := ChangeBRK(body);        // </ br>をCRLFに変換する
          body := ChangeImage(body);      // 埋め込み画像リンクを変換する
          body := Delete_href(body);      // 本文中のリンクタグを除去する
          //body := ChangeURL(body);        // ベタ書きURLをリンクタグに変換する
          body := ElimBodyTag(body);      // 本文内の整形タグを削除する（カクヨム限定）
          body := ChangeRuby(body);       // ルビのタグを変換する
          body := Restore2RealChar(body); // エスケースされた特殊文字を本来の文字に変換する

          if Length(capt) > 1 then
            TextPage.Add(AO_CPB + capt + AO_CPE);

          sp := UTF8Pos(SERRSTR, body);
          if (sp > 0) and (sp < 10) then
          begin
            TextPage.Add(AO_CPI + subt + AO_SEC);
            TextPage.Add('★HTMLページ読み込みエラー');
            Result := True;
          end else begin
            TextPage.Add(AO_SEB + subt + AO_SEE);
            TextPage.Add(body);
            TextPage.Add('');
            TextPage.Add(AO_PB2);
            TextPage.Add('');
          end;
        end else begin
          Writeln(subt + ' から本文を抽出出来ませんでした.');
        end;
      end;
    end;
  end;
end;

// 各話URLリストをもとに各話ページを読み込んで本文を取り出す
procedure LoadEachPage;
var
  i, n, cnt, sc: integer;
  line: string;
  CSBI: TConsoleScreenBufferInfo;
  CCI: TConsoleCursorInfo;
  hCOutput: THandle;
begin
  cnt := PageList.Count;
  hCOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hCOutput, CSBI);
  GetConsoleCursorInfo(hCOutput, CCI);
  Write('各話を取得中 [  0/' + Format('%3d', [cnt]) + ']');
  CCI.bVisible := False;
  SetConsoleCursorInfo(hCoutput, CCI);
  if StartN > 0 then
    i := StartN - 1
  else
    i := 0;
  n := 1;
  sc := cnt - i;

  while i < cnt do
  begin
    line := LoadFromHTML(PageList.Strings[i]);
    if line <> '' then
    begin
      ParsePage(line);
      SetConsoleCursorPosition(hCOutput, CSBI.dwCursorPosition);
      Write('各話を取得中 [' + Format('%3d', [i + 1]) + '/' + Format('%3d', [cnt]) + '(' + Format('%d', [(n * 100) div sc]) + '%)]');
      if hWnd <> 0 then
        SendMessage(hWnd, WM_DLINFO, n, 1);
      // ダウンロードを安定させるために0.5秒のインターバルを入れる
      Sleep(400);   // サーバーへの負担を減らすため、200 -> 400に変更 2024/7/10
    end;
    Inc(i);
    Inc(n);
  end;
  CCI.bVisible := True;
  SetConsoleCursorInfo(hCoutput, CCI);
  Writeln('');
end;

// トップページからタイトル、作者、前書き、各話情報を取り出す
procedure ParseCapter(MainPage: string);
var
  sp, ep: integer;
  ss, ts, title, auther, authurl, fn, sendstr: string;
  r: TRegExpr;
  conhdl: THandle;
begin
  Write('小説情報を取得中 ' + URL + ' ... ');
  r := TRegExpr.Create;
  try
    // タイトル名
    r.Expression  := STITLEB;
    r.InputString := MainPage;
    if r.Exec then
    begin
      sp := r.MatchPos[0];
      UTF8Delete(MainPage, 1, sp + r.MatchLen[0] - 1);
      sp := UTF8Pos(STITLEE, MainPage);
      if sp > 1 then
      begin
        ss := UTF8Copy(MainPage, 1, sp - 1);
        while (ss[1] <= ' ') do
          UTF8Delete(ss, 1, 1);
        // タイトル名からファイル名に使用できない文字を除去する
        title := PathFilter(Restore2RealChar(ss));
        // 引数に保存するファイル名を指定していなかった場合、タイトル名からファイル名を作成する
        if UTF8Length(Filename) = 0 then
        begin
          fn := title;
          if Length(fn) > 26 then
            UTF8Delete(fn, 27, UTF8Length(fn) - 26);
          if StartPage <> '' then
            fn := fn + '(' + StartPage + ')';
          Filename := Path + fn + '.txt';
        end;
        // タイトル名に"完結"が含まれていなければ先頭に小説の連載状況を追加する
        if UTF8Pos('完結', title) = 0 then
          title := NvStat + title;
        // タイトル名を保存
        TextPage.Add(title);
        LogFile.Add('タイトル：' + title);
        UTF8Delete(MainPage, 1, sp + UTF8Length(STITLEE));
        authurl := '';
        // 作者URL
        sp := UTF8Pos(SAUTHERB, MainPage);
        if sp > 1  then
        begin
          UTF8Delete(MainPage, 1, sp + UTF8Length(SAUTHERB) - 1);
          r.Expression  := SAUTHERM;
          r.InputString := MainPage;
          if r.Exec then
          begin
            ep := r.MatchPos[0];
            ts := UTF8Copy(MainPage, 1, ep - 1);
            authurl := 'https://kakuyomu.jp' + ts;  // 作者URL
            UTF8Delete(MainPage, 1, ep + r.MatchLen[0] - 1);
            ep := UTF8Pos(SAUTHERE, MainPage);
            if ep > 1 then
            begin
              auther := UTF8Copy(MainPage, 1, ep - 1);
              UTF8Delete(MainPage, 1, ep + Length(SAUTHERE));
            end;
            // 作者名を保存
            TextPage.Add(auther);
            TextPage.Add('');
            TextPage.Add(AO_PB2);
            TextPage.Add('');
            LogFile.Add('作者　　：' + auther);
            if authurl <> '' then
              LogFile.Add('作者URL : ' + authurl);
            // #$0D#$0Aを削除する
            MainPage := ElimCRLF(MainPage);
            UTF8Delete(MainPage, 1, ep + UTF8Length(SAUTHERE));
            // 前書き（あらすじ）
            r.Expression  := SHEADERB;
            r.InputString := MainPage;
            if r.Exec then
            begin
              sp := r.MatchPos[0];
              // 省略されていない前書きはソースの一番下にあるためコピーを作って作業する
              ts := UTF8Copy(MainPage, sp + UTF8Length(SHEADERB), UTF8Length(MainPage));
              ep := UTF8Pos(SHEADERE, ts);
              if ep > 1 then
              begin
                ts := UTF8Copy(ts, 1, ep - 1);
                // あらすじ部分の改行が\n表記となったため直接CRLFに置換する
                ts := UTF8StringReplace(ts, '\n', CRLF, [rfReplaceAll]);
                ts := ElimTag(ts);
                // 余分なタグを除去する
                sp := UTF8Pos('<', ts);
                if sp > 1 then
                  UTF8Delete(ts, sp, Length(ts));
                // 前書きの最後にある"…続きを読む"を削除する
                ts := UTF8StringReplace(ts, '…続きを読む', '', [rfReplaceAll]);
                ts := ChangeImage(ts);
                ts := ChangeAozoraTag(ts);
                TextPage.Add(AO_KKL);
                TextPage.Add(ts);  // 前書きに《》を使う作者がいたりして
                TextPage.Add(AO_KKR);
                TextPage.Add(AO_PB2);
                LogFile.Add('あらすじ：');
                LogFile.Add(ts);
              end;
            end;
            // 各話のURLを取得する
            sp := UTF8Pos(SSTRURLB, MainPage);
            while sp > 1 do
            begin
              UTF8Delete(MainPage, 1, sp + UTF8Length(SSTRURLB) - 1);
              ep := UTF8Pos(SSTRURLE, MainPage);
              if ep > 1 then
              begin
                ts := Copy(MainPage, 1, ep - 1);
                PageList.Add(URL + '/episodes/' + ts);
                UTF8Delete(MainPage, 1, ep + UTF8Length(SSTRURLE) - 1);
                sp := UTF8Pos(SSTRURLB, MainPage);
              end else
                Break;
            end;
            Writeln(IntToStr(PageList.Count) + ' 話の情報を取得しました.');
            // Naro2mobiから呼び出された場合は進捗状況をSendする
            if hWnd <> 0 then
            begin
              conhdl := GetStdHandle(STD_OUTPUT_HANDLE);
              sendstr := title + ',' + auther;
              Cds.dwData := PageList.Count - StartN + 1;
              Cds.cbData := (Length(sendstr) + 1) * SizeOf(Char);
              Cds.lpData := Pointer(sendstr);
              SendMessage(hWnd, WM_COPYDATA, conhdl, LPARAM(Addr(Cds)));
            end;
          end;
        end;
      end;
    end;
  finally
    r.Free;
  end;
end;

// 小説の連載状況をチェックする
function GetNovelStatus(MainPage: string): string;
var
  str: string;
  //m: TMatch;
  r: TRegExpr;
begin
  Result := '';
  r := TRegExpr.Create;
  try
    //m := TRegEx.Match(MainPage, '<ul class=.*?><li class=.*?><div class=.*?>.*?<!-- --> 全<!-- -->');
    r.Expression  := '<ul class=.*?><li class=.*?><div class=.*?>.*?<!-- --> 全<!-- -->';
    r.InputString := MainPage;
    //if m.Index > 1 then
    if r.Exec then
    begin
      //str := Copy(MainPage, m.Index, m.Length);
      str := UTF8Copy(MainPage, r.MatchPos[0], r.MatchLen[0]);
      if UTF8Pos('連載中', str) > 0 then
        Result := '【連載中】'
      else if UTF8Pos('完結済', str) > 0 then
        Result := '【完結】';
    end;
  finally
    r.Free;;
  end;
end;

var
  i: integer;
  op: string;

begin
  if ParamCount = 0 then
  begin
    Writeln('');
    Writeln('kakuyomudl ver4.0 2024/07/11 (c) INOUE, masahiro.');
    Writeln('  使用方法');
    Writeln('  kakuyomudl [-sDL開始ページ番号] 小説トップページのURL [保存するファイル名(省略するとタイトル名で保存します)]');
    Exit;
  end;
  ExitCode  := 0;
  hWnd      := 0;
  StartN    := 0;  // 開始ページ番号(0スタート)
  FileName  := '';
  StartPage := '';

  Path := ExtractFilePath(ParamStr(0));
  // オプション引数取得
  for i := 0 to ParamCount - 1 do
  begin
    op := ParamStr(i + 1);
    // Naro2mobiのWindowsハンドル
    if UTF8Pos('-h', op) = 1 then
    begin
      Delete(op, 1, 2);
      try
        hWnd := StrToInt(op);
      except
        Writeln('Error: Invalid Naro2mobi Handle.');
        ExitCode := -1;
        Exit;
      end;
    // DL開始ページ番号
    end else if UTF8Pos('-s', op) = 1 then
    begin
      Delete(op, 1, 2);
      StartPage := op;
      try
        StartN := StrToInt(op);
      except
        Writeln('Error: Invalid Start Page Number.');
        ExitCode := -1;
        Exit;
      end;
    // 作品URL
    end else if UTF8Pos('https:', op) = 1 then
    begin
      URL := op;
    // それ以外であれば保存ファイル名
    end else begin
      FileName := op;
      if UpperCase(ExtractFileExt(op)) <> '.TXT' then
        FileName := FileName + '.txt';
    end;
  end;

  if UTF8Pos('https://kakuyomu.jp/works/', URL) = 0 then
  begin
    Writeln('小説のURLが違います.');
    ExitCode := -1;
    Exit;
  end;

  Capter := '';
  TextLine := LoadFromHTML(URL);
  if TextLine <> '' then
  begin
    PageList := TStringList.Create;
    TextPage := TStringList.Create;
    LogFile  := TStringList.Create;
    LogFile.Add(URL);
    try
      NvStat := GetNovelStatus(TextLine);       // 小説の連載状況を取得
      ParseCapter(TextLine);                    // 小説の目次情報を取得
      if PageList.Count >= StartN then
      begin
        LoadEachPage;                           // 小説各話情報を取得
        try
          TextPage.WriteBOM := True;  // DelphiとLazarusでデフォルトの定義が違うため明示的に指定する
          LogFile.WriteBOM  := True;
          TextPage.SaveToFile(Filename, TEncoding.UTF8);
          LogFile.SaveToFile(ChangeFileExt(FileName, '.log'), TEncoding.UTF8);
          Writeln(Filename + ' に保存しました.');
        except
          ExitCode := -1;
          Writeln('ファイルの保存に失敗しました.');
        end;
      end else begin
        Writeln(URL + 'から小説情報を取得できませんでした.');
        ExitCode := -1;
      end;
    finally
      LogFile.Free;
      PageList.Free;
      TextPage.Free;
    end;
  end else begin
    Writeln(URL + 'からページ情報を取得できませんでした.');
    ExitCode := -1;
  end;
end.
