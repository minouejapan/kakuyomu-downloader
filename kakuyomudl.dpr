(*
  カクヨム小説ダウンローダー[kakuyomudl]

  2.3 2023/02/27  &#x????;にエンコードされている‼等のUnicode文字をデコードする処理を追加した
                  識別タグの文字列長さを定数からLength(識別文字定数)に変更した
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

{$R *.res}

{$R *.dres}

uses
  System.SysUtils,
  System.Classes,
  Windows,
  WinInet,
  WinAPI.Messages;

const
  // データ抽出用の識別タグ
  STITLEB  = '<h1 id="workTitle"><a href=';     // 小説表題
  STITLEE  = '</a>';
  SAUTHERB = '<span id="workAuthor-activityName"><a href=';   // 作者
  SAUTHERE = '</a>';
  SAUTHERG = '<i class="icon-official" title="Official"></i>';
  SHEADERB = 'js-work-introduction">'; // 前書き
  SHEADERE = '</p>';
  SCOVERB  = '<div id="coverImage"><img src="';
  SCOVERE  = '"';

  SSTRURLB = '<li class="widget-toc-episode">';  // 各話リンクURL
  SSTRURLM = '<a href="';
  SSTRURLE = '" ';
  SSTTLB   = '<span class="widget-toc-episode-titleLabel js-vertical-composition-item">';
  SSTTLE   = '</span>';

  SCAPTB   = '<p class="chapterTitle level1 js-vertical-composition-item"><span>';
  SCAPTB2   = '<p class="chapterTitle level2 js-vertical-composition-item"><span>';
  SCAPTE   = '</span>';
  SEPISB   = '<p class="widget-episodeTitle js-vertical-composition-item">';
  SEPISE   = '</p>';
  SBODYB   = '<p id="p1"';
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
  Capter, URL, Path, FileName, NvStat, strhdl: string;
  RBuff: TMemoryStream;
  TBuff: TStringList;
  hWnd: THandle;
  CDS: TCopyDataStruct;


// WinINetを用いたHTMLファイルのダウンロード
function LoadFromHTML(URLadr: string; var RBuff: TMemoryStream): boolean;
var
  hSession    : HINTERNET;
  hService    : HINTERNET;
  dwBytesRead : DWORD;
  dwFlag      : DWORD;
  lpBuffer    : PChar;
begin
  Result   := True;
  hSession := InternetOpen('WinINet', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  RBuff.Clear;
  RBuff.Position := 0;

  if Assigned(hSession) then begin
    dwFlag   := INTERNET_FLAG_RELOAD;
    hService := InternetOpenUrl(hSession, PChar(URLadr), nil, 0, dwFlag, 0);
    if Assigned(hService ) then
    begin
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
          end else begin
            Result := False;
            break;
          end;
        end;
      finally
        FreeMem(lpBuffer);
      end;
    end;
    InternetCloseHandle(hService);
    RBuff.Position := 0;    // ポジションをリセット
  end else begin
    Result := False;
  end;
end;

// HTMLテキスト内のCR/LF(#$0D#$0A)を除去する
function ElimCRLF(Base: string): string;
begin
  Result := StringReplace(Base, #$0D#$0A, '', [rfReplaceAll]);
end;

// 前書き内のタグを削除する（カクヨム限定）
function ElimTag(Base: string): string;
var
  ps, pe: integer;
begin
  ps := Pos('<', Base);
  while ps > 0 do
  begin
    pe := Pos('>', Base);
    if pe > ps then
    begin
      Delete(Base, ps, pe - ps + 1);
      ps := Pos('<', Base);
    end else
      ps := 0;
  end;
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
  Base := StringReplace(Base, '</p>', '', [rfReplaceAll]);
  Base := StringReplace(Base, '</a>', '', [rfReplaceAll]);
  tmplist := TStringList.Create;
  try
    tmplist.Text := Base;
    for i := 0 to tmplist.Count - 1 do
    begin
      if Pos('class="blank">', tmplist[i]) > 0 then
        tmplist[i] := '';
      tmp := tmplist[i];
      p := Pos('">', tmp);
      if p > 0 then
      begin
        Delete(tmp, 1, p + 1);
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
  c: char;
begin
  while True do
  begin
    if Length(Base) = 0 then
      Break;
    c := Base[1];
    if Pos(c, ' 　'#$09#$0D#$0A) > 0 then
      Delete(Base, 1, 1)
    else
      Break;
  end;
  while True do
  begin
    p := Length(Base);
    if p = 0 then
      Break;
    c := Base[p];
    if Pos(c, ' 　'#$09#$0D#$0A) > 0 then
      Delete(Base, p, 1)
    else
      Break;
  end;
  Result := Base;
end;

// 本文の改行タグを改行コードに変換する
function ChangeBRK(Base: string): string;
begin
  Result := StringReplace(Base, '<br />', #13#10, [rfReplaceAll]);
end;

// 本文の青空文庫ルビ指定に用いられる文字があった場合誤作動しないように代替文字に変換する
function ChangeAozoraTag(Base: string): string;
var
  tmp: string;
begin
  tmp := StringReplace(Base, '《', '『',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '》', '』',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '｜', '‖',  [rfReplaceAll]);
  Result := tmp;
end;

// 本文のルビタグを青空文庫形式に変換する
function ChangeRuby(Base: string): string;
var
  tmp: string;
begin
  // <rp>タグを除去
  tmp := StringReplace(Base, '<rp>(</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>)</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>（</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>）</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rb>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</rb>', '', [rfReplaceAll]);
  // rubyタグを青空文庫形式に変換
  tmp := StringReplace(tmp,  '<ruby>', AO_RBI, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rt>',   AO_RBL, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</rt></ruby>', AO_RBR, [rfReplaceAll]);
  // カクヨムの傍点タグ？
  tmp := StringReplace(tmp,  '<em class="emphasisDots"><span>', AO_EMB, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<span>', AO_EMB,  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</span></em>', AO_EME,  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</span>', AO_EME,  [rfReplaceAll]);

  Result := tmp;
end;

// HTML特殊文字の処理
// 1)エスケープ文字列 → 実際の文字
// 2)&#x????; → 通常の文字
function Restore2RealChar(Base: string): string;
var
  tmp, cd: string;
  p, w: integer;
  ch: Char;
begin
  // エスケープされた文字
  tmp := StringReplace(Base, '&lt;',      '<',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&gt;',      '>',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&quot;',    '"',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&nbsp;',    ' ',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&yen;',     '\',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&brvbar;',  '|',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&copy;',    '©',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&amp;',     '&',  [rfReplaceAll]);
  // &#x????;にエンコードされた文字をデコードする (2023/2/27)
  p := Pos('&#x', tmp);
  while p > 0 do
  begin
    Delete(tmp, p, 3);
    cd := Copy(tmp, p, 4);
    w := StrToInt('$' + cd);
    ch := Char(w);
    Delete(tmp, p, 5);
    Insert(ch, tmp, p);
    P := Pos('&#x', tmp);
  end;
  Result := tmp;
end;

// 埋め込まれた画像リンクを青空文庫形式に変換する
// 但し、画像ファイルはダウンロードせずにリンク先をそのまま埋め込む
function ChangeImage(Base: string): string;
var
  p, p2: integer;
  lnk: string;
begin
  p := Pos(SPICTB, Base);
  while p > 0 do
  begin
    Delete(Base, p, Length(SPICTB));
    p2 := Pos(SPICTE, Base);
    if p2 > 1 then
    begin
      lnk := Copy(Base, p, p2 - p);
      Delete(Base, p, p2 - p + Length(SPICTE));
      Insert(AO_PIE, Base, p);
      Insert(lnk, Base, p);
      Insert(AO_PIB, Base, p);
    end;
    p := Pos(SPICTB, Base);
  end;
  Result := Base;
end;

// Delphi XE2ではPos関数に検索開始位置を指定出来ないための代替え
function PosN(SubStr, Str: string; StartPos: integer): integer;
var
  tmp: string;
  p: integer;
begin
  tmp := Copy(Str, StartPos, Length(Str));
  p := Pos(SubStr, tmp);
  if p > 0 then
    Result := p + StartPos - 1  // 1ベーススタートのため1を引く
  else
    Result := 0;
end;

// 本文のリンクタグを除去する
function Delete_href(Base: string): string;
var
  p, p2: integer;
begin
  p := Pos(SHREFB, Base);
  while p > 0 do
  begin
    p2 := PosN(SHREFE, Base, p);
    if p2 > 1 then
    begin
      Delete(Base, p, p2 - p + 2);
    end;
    p := Pos(SHREFB, Base);
  end;
  Result := Base;
end;

// 本文にベタで貼られたURLのリンク先を青空文庫風タグ「＃リンク（）］で
// 囲む
function ChangeURL(Base: string): string;
var
  p, p2: integer;
  lnk: string;
begin
  p := Pos(SURLB, Base);
  while p > 0 do
  begin
    p2 := PosN('</p>', Base, p);
    if p2 > 1 then
    begin
      lnk := Copy(Base, p, p2 - p);
      Delete(Base, p, p2 - p);
      Insert(AO_LIB + lnk + AO_LIE, Base, p);
    end;
    p := PosN(SURLB, Base, p2);
  end;
  Result := Base;
end;

// タイトル名をファイル名として使用出来るかどうかチェックし、使用不可文字が
// あれば修正する('-'に置き換える)
// フォルダ名の最後が'.'の場合、フォルダ作成時に"."が無視されてフォルダ名が
// 見つからないことになるため'.'も'-'で置き換える(2019/12/20)
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

// 小説本文をHTMLから抜き出して整形する
function PersPage(Page: string): Boolean;
var
  sp, ep: integer;
  capt, subt, body: string;
begin
  Result := False;

  Page := ChangeAozoraTag(Page);  // 最初に青空文庫のルビタグ文字｜《》を変換する

  //Page := ElimCRLF(Page);
  // 章(Chapter)＋話(Episode)構成の場合と話(Episode)だけの場合があるため、まずは章があれば処理して次に話を処理する
  sp := Pos(SCAPTB, Page);  // 章(Chapter Level-1)をチェック
  if sp > 1 then
  begin
    Delete(Page, 1, Length(SCAPTB) + sp - 1);
    ep := Pos(SCAPTE, Page);
    if ep > 1 then
    begin
      capt := Copy(Page, 1, ep - 1);
      capt := TrimSpace(capt);
      if Capter = capt then
        capt := ''
      else
        Capter := capt;
      Delete(Page, 1, Length(SCAPTE) + ep - 1);
    end;
  end;
  sp := Pos(SCAPTB2, Page);  // 章(Chapter Level-2)をチェック
  if sp > 1 then
  begin
    Delete(Page, 1, Length(SCAPTB) + sp - 1);
    ep := Pos(SCAPTE, Page);
    if ep > 1 then
    begin
      capt := Copy(Page, 1, ep - 1);
      capt := TrimSpace(capt);
      capt := Restore2RealChar(capt);
      if Capter = capt then
        capt := ''
      else
        Capter := capt;
      Delete(Page, 1, Length(SCAPTE) + ep - 1);
    end;
  end;
  sp := Pos(SEPISB, Page);  // 話(Episode)をチェック
  if sp > 1 then
  begin
    Delete(Page, 1, Length(SEPISB) + sp - 1);
    ep := Pos(SEPISE, Page);
    if ep > 1 then
    begin
      subt := Copy(Page, 1, ep - 1);
      subt := TrimSpace(subt);
      subt := Restore2RealChar(subt);
      Delete(Page, 1, Length(SEPISE) + ep);
      sp := Pos(SBODYB, Page);
      if sp > 1 then
      begin
        Delete(Page, 1, Length(SBODYB) + sp - 1);
        sp := Pos(SBODYM, Page);
        if sp > 0 then
          Delete(Page, 1, sp);
        ep := Pos(SBODYE, Page);
        if ep > 1 then
        begin
          body := Copy(Page, 1, ep - 1);
          body := ChangeBRK(body);        // </ br>をCRLFに変換する
          body := Delete_href(body);      // 本文中のリンクタグを除去する
          body := ChangeURL(body);        // ベタ書きURLをリンクタグに変換する
          body := ElimBodyTag(body);      // 本文内の整形タグを削除する（カクヨム限定）
          //body := ChangeAozoraTag(body);  // 青空文庫のルビタグ文字｜《》を変換する
          body := ChangeRuby(body);       // ルビのタグを変換する
          body := ChangeImage(body);      // 埋め込み画像リンクを変換する
          body := Restore2RealChar(body); // エスケースされた特殊文字を本来の文字に変換する

          if Length(capt) > 1 then
            TextPage.Add(AO_CPB + capt + AO_CPE);

          sp := Pos(SERRSTR, body);
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
        end;
      end;
    end;
  end;
end;

// 各話URLリストをもとに各話ページを読み込んで本文を取り出す
procedure LoadEachPage;
var
  i, n, cnt: integer;
  RBuff: TMemoryStream;
  TBuff: TStringList;
  CSBI: TConsoleScreenBufferInfo;
  CCI: TConsoleCursorInfo;
  hCOutput: THandle;
begin
  RBuff := TMemoryStream.Create;
  try
    TBuff := TStringList.Create;
    try
      i := 0;
      n := 1;
      cnt := PageList.Count;
      hCOutput := GetStdHandle(STD_OUTPUT_HANDLE);
      GetConsoleScreenBufferInfo(hCOutput, CSBI);
      GetConsoleCursorInfo(hCOutput, CCI);
      Write('各話を取得中 [  0/' + Format('%3d', [cnt]) + ']');
      CCI.bVisible := False;
      SetConsoleCursorInfo(hCoutput, CCI);
      while i < cnt do
      begin
        RBuff.Clear;
        if LoadFromHTML(PageList.Strings[i], RBuff) then
        begin
          RBuff.Position := 0;
          TBuff.Clear;
          TBuff.WriteBOM := False;
          TBuff.LoadFromStream(RBuff, TEncoding.UTF8);
          PersPage(TBuff.Text);
          SetConsoleCursorPosition(hCOutput, CSBI.dwCursorPosition);
          Write('各話を取得中 [' + Format('%3d', [n]) + '/' + Format('%3d', [cnt]) + '(' + Format('%d', [(n * 100) div cnt]) + '%)]');
          if hWnd <> 0 then
            SendMessage(hWnd, WM_DLINFO, n, 1);
        end;
        Inc(i);
        Inc(n);
      end;
    finally
      TBuff.Free;
    end;
  finally
    RBuff.Free;
  end;
  CCI.bVisible := True;
  SetConsoleCursorInfo(hCoutput, CCI);
  Writeln('');
end;

// トップページからタイトル、作者、前書き、各話情報を取り出す
procedure PersCapter(MainPage: string);
var
  sp, ep: integer;
  ss, ts, title, auther, cover, fn, sendstr: string;
  conhdl: THandle;
begin
  Write('小説情報を取得中 ' + URL + ' ... ');
  // 表紙画像
  sp := Pos(SCOVERB, MainPage);
  if sp > 0 then
  begin
    ep := PosN(SCOVERE, MainPage, sp + Length(SCOVERB));
    if ep > 0 then
      cover := Copy(MainPage, sp + Length(SCOVERB), ep - sp - Length(SCOVERB))
    else
      cover := '';
  end;
  // タイトル名
  sp := Pos(STITLEB, MainPage);
  if sp > 0 then
  begin
    Delete(MainPage, 1, sp + Length(STITLEB) - 1);
    // タイトルの前にあるリンク情報を削除する
    sp := Pos('">', MainPage);
    Delete(MainPage, 1, sp + 1);
    sp := Pos(STITLEE, MainPage);
    if sp > 1 then
    begin
      ss := Copy(MainPage, 1, sp - 1);
      while (ss[1] <= ' ') do
        Delete(ss, 1, 1);
      // タイトル名からファイル名に使用できない文字を除去する
      title := PathFilter(ss);
      // 引数に保存するファイル名を指定していなかった場合、タイトル名からファイル名を作成する
      if Length(Filename) = 0 then
      begin
        fn := title;
        if Length(fn) > 26 then
          Delete(fn, 27, Length(fn) - 26);
        Filename := Path + fn + '.txt';
      end;
      // タイトル名に"完結"が含まれていなければ先頭に小説の連載状況を追加する
      if Pos('完結', title) = 0 then
        title := NvStat + title;
      // タイトル名を保存
      TextPage.Add(title);
      LogFile.Add('タイトル：' + title);
      Delete(MainPage, 1, sp + Length(STITLEE));
      // 作者名
      sp := Pos(SAUTHERB, MainPage);
      if sp > 1  then
      begin
        Delete(MainPage, 1, sp + Length(SAUTHERB) - 1);
        ep := Pos(SAUTHERE, MainPage);
        if ep > 1 then
        begin
          ts := Copy(MainPage, 1, ep - 1);
          sp := Pos('">', ts);
          Delete(ts, 1, sp + 1);
          auther := ts;
          sp := Pos(SAUTHERG, auther);
          if sp > 1 then
            Delete(auther, sp, Length(SAUTHERG));
          // 作者名を保存
          TextPage.Add(auther);
          // 表紙画像があればタグを挿入する
          if cover <> '' then
            TextPage.Add(AO_CVB + cover + AO_CVE);
          TextPage.Add('');
          TextPage.Add(AO_PB2);
          TextPage.Add('');
          LogFile.Add('作者　　：' + auther);
          // #$0D#$0Aを削除する
          MainPage := ElimCRLF(MainPage);
          Delete(MainPage, 1, ep + Length(SAUTHERE));
          // 前書き（あらすじ）
          sp := Pos(SHEADERB, MainPage);
          if sp > 1 then
          begin
            Delete(MainPage, 1, sp + Length(SHEADERB) - 1);
            ep := Pos(SHEADERE, MainPage);
            if ep > 1 then
            begin
              ts := Copy(MainPage, 1, ep - 1);
              ts := ChangeBRK(ts);
              ts := ElimTag(ts);
              // 余分なタグを除去する
              sp := Pos('<', ts);
              if sp > 1 then
                Delete(ts, sp, Length(ts));
              // 前書きの最後にある"…続きを読む"を削除する
              ts := StringReplace(ts, '…続きを読む', '', [rfReplaceAll]);
              TextPage.Add(AO_KKL);
              TextPage.Add(ChangeAozoraTag(ts));  // 前書きに《》を使う作者がいたりして
              TextPage.Add(AO_KKR);
              TextPage.Add(AO_PB2);
              LogFile.Add('あらすじ：');
              LogFile.Add(ts);
            end;
          end;
          // 各話のURLを取得する
          sp := Pos(SSTRURLB, MainPage);
          while sp > 1 do
          begin
            Delete(MainPage, 1, sp + Length(SSTRURLB) - 1);
            ep := Pos(SSTRURLM, MainPage);
            if ep >0 then
              Delete(MainPage, 1, ep + Length(SSTRURLM) - 1);
            ep := Pos(SSTRURLE, MainPage);
            if ep > 1 then
            begin
              ts := Copy(MainPage, 1, ep - 1);
              PageList.Add('https://kakuyomu.jp' + ts);
              Delete(MainPage, 1, ep + Length(SSTRURLE) - 1);
              sp := Pos(SSTRURLB, MainPage);
            end else
              Break;
          end;
          Writeln(IntToStr(PageList.Count) + ' 話の情報を取得しました.');
          // Naro2mobiから呼び出された場合は進捗状況をSendする
          if hWnd <> 0 then
          begin
            conhdl := GetStdHandle(STD_OUTPUT_HANDLE);
            sendstr := title + ',' + auther;
            Cds.dwData := PageList.Count;
            Cds.cbData := (Length(sendstr) + 1) * SizeOf(Char);
            Cds.lpData := Pointer(sendstr);
            SendMessage(hWnd, WM_COPYDATA, conhdl, LPARAM(Addr(Cds)));
          end;
        end;
      end;
    end;
  end;
end;

// 小説の連載状況をチェックする
function GetNovelStatus(MainPage: string): string;
var
  str: string;
  p: integer;
begin
  Result := '';
  p := Pos(SHEAD, MainPage);
  if p > 0 then
  begin
    str := Copy(MainPage, p, 200);
    if Pos('連載中', str) > 0 then
      Result := '【連載中】'
    else if Pos('完結', str) > 0 then
      Result := '【完結】';
  end;
end;

begin
  if ParamCount = 0 then
  begin
    Writeln('');
    Writeln('kakuyomudl ver2.3 2023/2/27 (c) INOUE, masahiro.');
    Writeln('  使用方法');
    Writeln('  kakuyomudl 小説トップページのURL [保存するファイル名(省略するとタイトル名で保存します)]');
    Exit;
  end;
  ExitCode := 0;
  hWnd := 0;

  Path := ExtractFilePath(ParamStr(0));
  URL := ParamStr(1);
  if ParamCount > 1 then
  begin
    FileName := ParamStr(2);
    if ParamCount = 3 then
    begin
      strhdl := ParamStr(3);
      if Pos('-h', strhdl) = 1 then
      begin
        Delete(strhdl, 1, 2);
        hWnd := StrToInt(strhdl);
      end;
    end;
  end else
    FileName := '';
  if Pos('https://kakuyomu.jp/works/', URL) = 0 then
  begin
    Writeln('小説のURLが違います.');
    ExitCode := -1;
    Exit;
  end;

  Capter := '';
  RBuff  := TMemoryStream.Create;
  try
    if LoadFromHTML(URL, RBuff) then
    begin
      TBuff := TStringList.Create;
      try
        RBuff.Position := 0;
        TBuff.WriteBOM := False;
        TBuff.LoadFromStream(RBuff, TEncoding.UTF8);
        PageList := TStringList.Create;
        TextPage := TStringList.Create;
        LogFile  := TStringList.Create;
        LogFile.Add(URL);
        try
          NvStat := GetNovelStatus(TBuff.Text); // 小説の連載状況を取得
          PersCapter(TBuff.Text);               // 小説の目次情報を取得
          if PageList.Count > 0 then
          begin
            LoadEachPage;                       // 小説各話情報を取得
            try
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
      finally
        TBuff.Free;
      end;
    end else begin
      Writeln(URL + 'からページ情報を取得できませんでした.');
      ExitCode := -1;
    end;
  finally
    RBuff.Free;
  end;
end.
