### kakuyomu-downloader
kakuyomudlはカクヨムで公開されている小説を青空文庫形式のテキストファイルでダウンロードするためのツールです。

### 動作環境
Windows10/11上のコマンドプロンプト上で動作します。

### 実行ファイルの作り方
ver4.0からDelphi/Lazarusどちらからでもビルド出来るようにしました。

Delphi (XE2以降)の場合はkakuyomudl.dprojを開いてビルドしてください。

Lazarus (3.0以降)の場合はkakuyomudl.lpiを開いてビルドしてください。

尚、ビルドするためにはTRegExprの最新版が必要です。TRegExprは https://github.com/andgineer/TRegExpr から取得してください。srcフォルダー内のregexpr.pas、regexpr_compilers.inc、regexpr_unicodedata.pasの3つのファイルをkakuyomudlプロジェクトソースファイルと同じフォルダにコピーして下さい。

#### バージョン情報を編集したい場合
　verinfo.rcファイルをテキストファイルとして開いて編集してください。尚、編集後は文字コードをShift-JISとして保存する必要があります。

　編集後はコマンドラインから、rc verinfo.rcを実行すればバージョン情報リソースファイルverinfo.resが作成されます。rc.exeはDelphiやVisual Studioをインストールしていればパスが通たフォルダー内に存在しているはずです。


### 使い方
コマンドプロンプト上で、
kakuyomudl ダウンロードしたいアルファポリス小説トップページのURL (保存したいテキストファイル名)と入力して実行キーを押します。正常に実行されればkakuyomudl.exeがあるフォルダにダウンロードした小説が青空文庫形式のテキストファイルで保存されます。

尚、保存したファイル名の指定は省略できます。省略した場合はダウンロードした小説のタイトル名からファイル名を作成して保存します。

詳しい使い方は http://m-and-i.my.coocan.jp/freesoft/naro2mobi/%E5%A4%96%E9%83%A8%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%80%E3%83%BC%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9.html を参照してください。

### 禁止事項
1.kakuyomudlを用いてWeb小 説サイトからダウンロードしたテキストファイルの第三者への販売や不特定多数への配信。 

2.ダウンロードしたオリジナル作品を著作者の了解なく加工（文章の流用や作品の翻訳等）しての再公開。 

3.その他、著作者の権利を踏みにじるような行為。 


### ライセンス
MIT
