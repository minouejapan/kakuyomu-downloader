(*
  �J�N���������_�E�����[�_�[[kakuyomudl]

      2022/09/26  Lazarus(FPC)�ŃR���p�C���o����悤�ɂ����i�^�[�Q�b�g��Windows�̂݁j
  2.0 2022/08/05  �^�C�g�����̐擪�ɘA�ڏ󋵁i�A�ڒ��E�����j��ǉ�����悤�ɂ���
  1.9 2022/03/02  �O�����ɐ󕶌Ƀ^�O�����邱�Ƃ����邽�ߑ�֕�����������ǉ�����
      2021/12/15  GitHub�ɏグ�邽�߃\�[�X�R�[�h�𐮗�����
  1.8 2021/10/07  �G�s�\�[�h��1�b�̏ꍇ�Ƀ_�E�����[�h�o���Ȃ������s����C������
                  �O�������Ȃ��ꍇ�_�E�����[�h�Ɏ��s����s����C������
  1.7 2021/09/26  �\���摜������΃^�O��}�����鏈�����
  1.6 2021/09/16  �}�G�̃^�O������ǉ�����
                  �x�^URL���m�������N�n�^�O��������悤�ɂ���
  1.5 2021/09/02  �ۖT�_�^�O�̌�L���C��
  1.4 2021/07/28  �J�N�����̓���ȖT�_�^�O�ɑΉ�
  1.3 2021/07/09  �O�����𐳂����F���ł��Ȃ������s����C��
                  �e�y�[�W�̖{���𐳂����F���ł��Ȃ������s����C��
                  �����Â�����ʂɗp�����^�O�̌`�������ނ����Ȃ��ƌ��ߑł����Ă������Ƃ�����
  1.2 2021/07/03  Naro2mobi����N�������ۂɐi���󋵂�Naro2mobi���ɒm�点��悤�ɂ���
  1.1 2021/07/01  �͂̔F�����s���S�������s����C��(chapter level-1��level-2��������)
  1.0 2021/06/30  alphadl�̃\�[�X�R�[�h���e���v���[�g�Ƃ��ăJ�N�����p�Ƃ��č쐬
*)

program kakuyomudl;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,   // System.SysUtils  �\�[�X�R�[�h�̈Ⴂ�͂��̂R�̃��j�b�g�������ł�
  Classes,    // System.Classes
  Windows,
  WinInet,
  Messages;   // WinAPI.Messages

const
  // �f�[�^���o�p�̎��ʃ^�O
  STITLEB  = '<h1 id="workTitle"><a href=';     // �����\��
  STITLEE  = '</a>';
  SAUTHERB = '<span id="workAuthor-activityName"><a href=';   // ���
  SAUTHERE = '</a>';
  SAUTHERG = '<i class="icon-official" title="Official"></i>';
  SHEADERB = 'js-work-introduction">'; // �O����
  SHEADERE = '</p>';
  SCOVERB  = '<div id="coverImage"><img src="';
  SCOVERE  = '"';

  SSTRURLB = '<li class="widget-toc-episode">';  // �e�b�����NURL
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

  SHEAD    = '<h3 class="heading-level2">�ڎ�</h3>';

  ITITLEB  = 27;  // �����\��
  ITITLEE  = 4;
  IAUTHERB = 43;  // ���
  IAUTHERE = 4;
  IAUTHERG = 46;
  IHEADERB = 22;  // �O����
  IHEADERE = 4;
  //ISTRURLB = 52;
  ISTRURLB = 31;
  ISTRURLM = 9;
  ISTRURLE = 2;
  ISTTLB   = 73;
  ISTTLE   = 7;
  ICOVERB  = 31;
  ICOVERE  = 1;

  ICAPTB   = 66;
  ICAPTE   = 7;
  IEPISB   = 60;
  IEPISE   = 4;
  IBODYB   = 10;
  IBODYM   = 1;
  IBODYE   = 6;

  IPICTB   = 10;
  IPICTM   = 0;
  IPICTE   = 13;

  // �󕶌Ɍ`��
  AO_RBI = '�b';							// ���r�̂�����n��(�K�������ł͂Ȃ�)
  AO_RBL = '�s';              // ���r�n��
  AO_RBR = '�t';              // ���r�I���
  AO_TGI = '�m��';            // �󕶌ɏ����ݒ�J�n
  AO_TGO = '�n';              //        �V       �I��
  AO_CPI = '�m���u';          // ���o���̊J�n
  AO_CPT = '�v�͑匩�o���n';	// ��
  AO_SEC = '�v�͒����o���n';  // �b
  AO_PRT = '�v�͏����o���n';
  AO_DAI = '�m����������';		// �u���b�N�̎������J�n
  AO_DAO = '�m�������Ŏ������I���n';
  AO_DAN = '�������n';
  AO_PGB = '�m�������n';			// �����Ɖ�y�[�W�̓y�[�W����Ȃ̂����J������
  AO_PB2 = '�m�����y�[�W�n';	// ���肩�̈Ⴂ�����邪�ǂ�����y�[�W����Ƃ���
  AO_SM1 = '�v�ɖT�_�n';			// ���r�T�_
  AO_SM2 = '�v�ɊۖT�_�n';		// ���r�T�_ �ǂ����sesami_dot�ň���
  AO_EMB = '�m���ۖT�_�n';        // ���]�J�n
  AO_EME = '�m���ۖT�_�I���n';  // �T�_�I���
  AO_KKL = '�m����������r�͂݁n' ;     // �{���͌r�͂ݔ͈͂̎w�肾���A�O������㏑������
  AO_KKR = '�m�������Ōr�͂ݏI���n';  // ��i�����������ŕ\�L���邽�߂Ɏg�p����
  AO_END = '��{�F';          // �y�[�W�t�b�_�J�n�i�K������Ƃ͌���Ȃ��j
  AO_PIB = '�m�������N�̐}�i';          // �摜���ߍ���
  AO_PIE = '�j����n';        // �摜���ߍ��ݏI���
  AO_LIB = '�m�������N�i';          // �摜���ߍ���
  AO_LIE = '�j����n';        // �摜���ߍ��ݏI���
  AO_CVB = '�m���\���̐}�i';  // �\���摜�w��
  AO_CVE = '�j����n';        // �I���

  CRLF   = #$0D#$0A;

// ���[�U���b�Z�[�WID
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


// WinINet��p����HTML�t�@�C���̃_�E�����[�h
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
    RBuff.Position := 0;    // �|�W�V���������Z�b�g
  end else begin
    Result := False;
  end;
end;

// HTML�e�L�X�g����CR/LF(#$0D#$0A)����������
function ElimCRLF(Base: string): string;
begin
  Result := StringReplace(Base, #$0D#$0A, '', [rfReplaceAll]);
end;

// �O�������̃^�O���폜����i�J�N��������j
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

// �{�����̗]�v�ȃ^�O���폜����i�J�N��������j
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

// �w�肳�ꂽ������̑O�ƌ�̃X�y�[�X(' '/'�@'/#$20/#$09/#$0D/#$0A)����������
// '�@�@�����@��@�@' �� '�����@��'
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
    if Pos(c, ' �@'#$09#$0D#$0A) > 0 then
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
    if Pos(c, ' �@'#$09#$0D#$0A) > 0 then
      Delete(Base, p, 1)
    else
      Break;
  end;
  Result := Base;
end;

// �{���̉��s�^�O�����s�R�[�h�ɕϊ�����
function ChangeBRK(Base: string): string;
begin
  Result := StringReplace(Base, '<br />', #13#10, [rfReplaceAll]);
end;

// �{���̐󕶌Ƀ��r�w��ɗp�����镶�����������ꍇ��쓮���Ȃ��悤�ɑ�֕����ɕϊ�����
function ChangeAozoraTag(Base: string): string;
var
  tmp: string;
begin
  tmp := StringReplace(Base, '�s', '�w',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '�t', '�x',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '�b', '?',  [rfReplaceAll]);
  Result := tmp;
end;

// �{���̃��r�^�O��󕶌Ɍ`���ɕϊ�����
function ChangeRuby(Base: string): string;
var
  tmp: string;
begin
  // <rp>�^�O������
  tmp := StringReplace(Base, '<rp>(</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>)</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>�i</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rp>�j</rp>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rb>', '', [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</rb>', '', [rfReplaceAll]);
  // ruby�^�O��󕶌Ɍ`���ɕϊ�
  tmp := StringReplace(tmp,  '<ruby>', AO_RBI, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<rt>',   AO_RBL, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</rt></ruby>', AO_RBR, [rfReplaceAll]);
  // �J�N�����̖T�_�^�O�H
  tmp := StringReplace(tmp,  '<em class="emphasisDots"><span>', AO_EMB, [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<span>', AO_EMB,  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</span></em>', AO_EME,  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '</span>', AO_EME,  [rfReplaceAll]);

  Result := tmp;
end;

// HTML���ꕶ���̏����i�G�X�P�[�v�����񁨎��ۂ̕����j
function Restore2RealChar(Base: string): string;
var
  tmp: string;
begin
  tmp := StringReplace(Base, '&lt;',      '<',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&gt;',      '>',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&quot;',    '"',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&nbsp;',    ' ',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&yen;',     '\',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&brvbar;',  '|',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&copy;',    'c',  [rfReplaceAll]);
  tmp := StringReplace(tmp,  '&amp;',     '&',  [rfReplaceAll]);
  Result := tmp;
end;

// ���ߍ��܂ꂽ�摜�����N��󕶌Ɍ`���ɕϊ�����
// �A���A�摜�t�@�C���̓_�E�����[�h�����Ƀ����N������̂܂ܖ��ߍ���
function ChangeImage(Base: string): string;
var
  p, p2: integer;
  lnk: string;
begin
  p := Pos(SPICTB, Base);
  while p > 0 do
  begin
    Delete(Base, p, IPICTB);
    p2 := Pos(SPICTE, Base);
    if p2 > 1 then
    begin
      lnk := Copy(Base, p, p2 - p);
      Delete(Base, p, p2 - p + IPICTE);
      Insert(AO_PIE, Base, p);
      Insert(lnk, Base, p);
      Insert(AO_PIB, Base, p);
    end;
    p := Pos(SPICTB, Base);
  end;
  Result := Base;
end;

// Delphi XE2�ł�Pos�֐��Ɍ����J�n�ʒu���w��o���Ȃ����߂̑�ւ�
function PosN(SubStr, Str: string; StartPos: integer): integer;
var
  tmp: string;
  p: integer;
begin
  tmp := Copy(Str, StartPos, Length(Str));
  p := Pos(SubStr, tmp);
  if p > 0 then
    Result := p + StartPos - 1  // 1�x�[�X�X�^�[�g�̂���1������
  else
    Result := 0;
end;

// �{���̃����N�^�O����������
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

// �{���Ƀx�^�œ\��ꂽURL�̃����N���󕶌ɕ��^�O�u�������N�i�j�n��
// �͂�
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

// �^�C�g�������t�@�C�����Ƃ��Ďg�p�o���邩�ǂ����`�F�b�N���A�g�p�s������
// ����ΏC������('-'�ɒu��������)
// �t�H���_���̍Ōオ'.'�̏ꍇ�A�t�H���_�쐬����"."����������ăt�H���_����
// ������Ȃ����ƂɂȂ邽��'.'��'-'�Œu��������(2019/12/20)
function PathFilter(PassName: string): string;
var
	i, l: integer;
  path: string;
  tmp: AnsiString;
  ch: char;
begin
  // �t�@�C��������UShiftJIS�ɕϊ����čēxUnicode�����邱�Ƃ�ShiftJIS�Ŏg�p
  // �o���Ȃ���������������
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

// �����{����HTML���甲���o���Đ��`����
function PersPage(Page: string): Boolean;
var
  sp, ep: integer;
  capt, subt, body: string;
begin
  Result := False;

  Page := ChangeAozoraTag(Page);  // �ŏ��ɐ󕶌ɂ̃��r�^�O�����b�s�t��ϊ�����

  //Page := ElimCRLF(Page);
  // ��(Chapter)�{�b(Episode)�\���̏ꍇ�Ƙb(Episode)�����̏ꍇ�����邽�߁A�܂��͏͂�����Ώ������Ď��ɘb����������
  sp := Pos(SCAPTB, Page);  // ��(Chapter Level-1)���`�F�b�N
  if sp > 1 then
  begin
    Delete(Page, 1, ICAPTB + sp - 1);
    ep := Pos(SCAPTE, Page);
    if ep > 1 then
    begin
      capt := Copy(Page, 1, ep - 1);
      capt := TrimSpace(capt);
      if Capter = capt then
        capt := ''
      else
        Capter := capt;
      Delete(Page, 1, ICAPTE + ep - 1);
    end;
  end;
  sp := Pos(SCAPTB2, Page);  // ��(Chapter Level-2)���`�F�b�N
  if sp > 1 then
  begin
    Delete(Page, 1, ICAPTB + sp - 1);
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
      Delete(Page, 1, ICAPTE + ep - 1);
    end;
  end;
  sp := Pos(SEPISB, Page);  // �b(Episode)���`�F�b�N
  if sp > 1 then
  begin
    Delete(Page, 1, IEPISB + sp - 1);
    ep := Pos(SEPISE, Page);
    if ep > 1 then
    begin
      subt := Copy(Page, 1, ep - 1);
      subt := TrimSpace(subt);
      subt := Restore2RealChar(subt);
      Delete(Page, 1, IEPISE + ep);
      sp := Pos(SBODYB, Page);
      if sp > 1 then
      begin
        Delete(Page, 1, IBODYB + sp - 1);
        sp := Pos(SBODYM, Page);
        if sp > 0 then
          Delete(Page, 1, sp);
        ep := Pos(SBODYE, Page);
        if ep > 1 then
        begin
          body := Copy(Page, 1, ep - 1);
          body := ChangeBRK(body);        // </ br>��CRLF�ɕϊ�����
          body := Delete_href(body);      // �{�����̃����N�^�O����������
          body := ChangeURL(body);        // �x�^����URL�������N�^�O�ɕϊ�����
          body := ElimBodyTag(body);      // �{�����̐��`�^�O���폜����i�J�N��������j
          //body := ChangeAozoraTag(body);  // �󕶌ɂ̃��r�^�O�����b�s�t��ϊ�����
          body := ChangeRuby(body);       // ���r�̃^�O��ϊ�����
          body := ChangeImage(body);      // ���ߍ��݉摜�����N��ϊ�����
          body := Restore2RealChar(body); // �G�X�P�[�X���ꂽ���ꕶ����{���̕����ɕϊ�����

          if Length(capt) > 1 then
            TextPage.Add(AO_CPI + capt + AO_CPT);

          sp := Pos(SERRSTR, body);
          if (sp > 0) and (sp < 10) then
          begin
            TextPage.Add(AO_CPI + subt + AO_SEC);
            TextPage.Add('��HTML�y�[�W�ǂݍ��݃G���[');
            Result := True;
          end else begin
            TextPage.Add(AO_CPI + subt + AO_SEC);
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

// �e�bURL���X�g�����ƂɊe�b�y�[�W��ǂݍ���Ŗ{�������o��
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
      //Write(#$1B'7'); // �J�[�\���ʒu�ۑ�
      Write('�e�b���擾�� [  0/' + Format('%3d', [cnt]) + ']');
      CCI.bVisible := False;
      SetConsoleCursorInfo(hCoutput, CCI);
      //Write(#$1B'[?25l'); // �J�[�\����\��
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
          //Write(#$1B'8'); // �J�[�\���ʒu����
          SetConsoleCursorPosition(hCOutput, CSBI.dwCursorPosition);
          Write('�e�b���擾�� [' + Format('%3d', [n]) + '/' + Format('%3d', [cnt]) + '(' + Format('%d', [(n * 100) div cnt]) + '%)]');
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
  //Write(#$1B'[?25l'); // �J�[�\���\��
  Writeln('');
end;

// �g�b�v�y�[�W����^�C�g���A��ҁA�O�����A�e�b�������o��
procedure PersCapter(MainPage: string);
var
  sp, ep: integer;
  ss, ts, title, auther, cover, fn, sendstr: string;
  conhdl: THandle;
begin
  Write('���������擾�� ' + URL + ' ... ');
  // �\���摜
  sp := Pos(SCOVERB, MainPage);
  if sp > 0 then
  begin
    ep := PosN(SCOVERE, MainPage, sp + ICOVERB);
    if ep > 0 then
      cover := Copy(MainPage, sp + ICOVERB, ep - sp - ICOVERB)
    else
      cover := '';
  end;
  // �^�C�g����
  sp := Pos(STITLEB, MainPage);
  if sp > 0 then
  begin
    Delete(MainPage, 1, sp + ITITLEB - 1);
    // �^�C�g���̑O�ɂ��郊���N�����폜����
    sp := Pos('">', MainPage);
    Delete(MainPage, 1, sp + 1);
    sp := Pos(STITLEE, MainPage);
    if sp > 1 then
    begin
      ss := Copy(MainPage, 1, sp - 1);
      while (ss[1] <= ' ') do
        Delete(ss, 1, 1);
      // �^�C�g��������t�@�C�����Ɏg�p�ł��Ȃ���������������
      title := PathFilter(ss);
      // �����ɕۑ�����t�@�C�������w�肵�Ă��Ȃ������ꍇ�A�^�C�g��������t�@�C�������쐬����
      if Length(Filename) = 0 then
      begin
        fn := title;
        if Length(fn) > 26 then
          Delete(fn, 27, Length(fn) - 26);
        Filename := Path + fn + '.txt';
      end;
      // �^�C�g������"����"���܂܂�Ă��Ȃ���ΐ擪�ɏ����̘A�ڏ󋵂�ǉ�����
      if Pos('����', title) = 0 then
        title := NvStat + title;
      // �^�C�g������ۑ�
      TextPage.Add(title);
      LogFile.Add('�^�C�g���F' + title);
      Delete(MainPage, 1, sp + ITITLEE);
      // ��Җ�
      sp := Pos(SAUTHERB, MainPage);
      if sp > 1  then
      begin
        Delete(MainPage, 1, sp + IAUTHERB - 1);
        ep := Pos(SAUTHERE, MainPage);
        if ep > 1 then
        begin
          ts := Copy(MainPage, 1, ep - 1);
          sp := Pos('">', ts);
          Delete(ts, 1, sp + 1);
          auther := ts;
          sp := Pos(SAUTHERG, auther);
          if sp > 1 then
            Delete(auther, sp, IAUTHERG);
          // ��Җ���ۑ�
          TextPage.Add(auther);
          // �\���摜������΃^�O��}������
          if cover <> '' then
            TextPage.Add(AO_CVB + cover + AO_CVE);
          TextPage.Add('');
          TextPage.Add(AO_PB2);
          TextPage.Add('');
          LogFile.Add('��ҁ@�@�F' + auther);
          // #$0D#$0A���폜����
          MainPage := ElimCRLF(MainPage);
          Delete(MainPage, 1, ep + IAUTHERE);
          // �O�����i���炷���j
          sp := Pos(SHEADERB, MainPage);
          if sp > 1 then
          begin
            Delete(MainPage, 1, sp + IHEADERB - 1);
            ep := Pos(SHEADERE, MainPage);
            if ep > 1 then
            begin
              ts := Copy(MainPage, 1, ep - 1);
              ts := ChangeBRK(ts);
              ts := ElimTag(ts);
              // �]���ȃ^�O����������
              sp := Pos('<', ts);
              if sp > 1 then
                Delete(ts, sp, Length(ts));
              TextPage.Add(AO_KKL);
              TextPage.Add(ChangeAozoraTag(ts));  // �O�����Ɂs�t���g������҂������肵��
              TextPage.Add(AO_KKR);
              TextPage.Add(AO_PB2);
              LogFile.Add('���炷���F');
              LogFile.Add(ts);
            end;
          end;
          // �e�b��URL���擾����
          sp := Pos(SSTRURLB, MainPage);
          while sp > 1 do
          begin
            Delete(MainPage, 1, sp + ISTRURLB - 1);
            ep := Pos(SSTRURLM, MainPage);
            if ep >0 then
              Delete(MainPage, 1, ep + ISTRURLM - 1);
            ep := Pos(SSTRURLE, MainPage);
            if ep > 1 then
            begin
              ts := Copy(MainPage, 1, ep - 1);
              PageList.Add('https://kakuyomu.jp' + ts);
              Delete(MainPage, 1, ep + ISTRURLE - 1);
              sp := Pos(SSTRURLB, MainPage);
            end else
              Break;
          end;
          Writeln(IntToStr(PageList.Count) + ' �b�̏����擾���܂���.');
          // Naro2mobi����Ăяo���ꂽ�ꍇ�͐i���󋵂�Send����
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

// �����̘A�ڏ󋵂��`�F�b�N����
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
    if Pos('�A�ڒ�', str) > 0 then
      Result := '�y�A�ڒ��z'
    else if Pos('����', str) > 0 then
      Result := '�y�����z';
  end;
end;

begin
  if ParamCount = 0 then
  begin
    Writeln('');
    Writeln('kakuyomudl ver2.0 2022/8/5 (c) INOUE, masahiro.');
    Writeln('  �g�p���@');
    Writeln('  kakuyomudl �����g�b�v�y�[�W��URL [�ۑ�����t�@�C����(�ȗ�����ƃ^�C�g�����ŕۑ����܂�)]');
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
    Writeln('������URL���Ⴂ�܂�.');
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
          NvStat := GetNovelStatus(TBuff.Text); // �����̘A�ڏ󋵂��擾
          PersCapter(TBuff.Text);               // �����̖ڎ������擾
          if PageList.Count > 0 then
          begin
            LoadEachPage;                       // �����e�b�����擾
            try
              TextPage.SaveToFile(Filename, TEncoding.UTF8);
              LogFile.SaveToFile(ChangeFileExt(FileName, '.log'), TEncoding.UTF8);
              Writeln(Filename + ' �ɕۑ����܂���.');
            except
              ExitCode := -1;
              Writeln('�t�@�C���̕ۑ��Ɏ��s���܂���.');
            end;
          end else begin
            Writeln(URL + '���珬�������擾�ł��܂���ł���.');
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
      Writeln(URL + '����y�[�W�����擾�ł��܂���ł���.');
      ExitCode := -1;
    end;
  finally
    RBuff.Free;
  end;
end.


