### kakuyomu-downloader
kakuyomudlはカクヨムで公開されている小説を青空文庫形式のテキストファイルでダウンロードするためのツールです。

### 動作環境
Windows10上のコマンドプロンプト上で動作します。

### 実行ファイルの作り方
Delphi (XE2以降)でkakuyomudl.dprを開いてビルドしてください。
またはLazarus 2.2以降でkakuyomudl.lprを開いてビルドしてください。

### 使い方
コマンドプロンプト上で、
kakuyomudl ダウンロードしたいアルファポリス小説トップページのURL (保存したいテキストファイル名)と入力して実行キーを押します。正常に実行されればkakuyomudl.exeがあるフォルダにダウンロードした青空文庫形式のテキストファイルが補zんされます。

尚、保存したファイル名の指定は省略できます。省略した場合はダウンロードした小説のタイトル名からファイル名を作成して保存します。

### カクヨムのダウンロードについて
アルファポリスのような連続ダウンロード制限がないため、Windows標準のインターネットAPIであるWinINetを用いてダウンロードしています。

### ライセンス
Apache2.0
