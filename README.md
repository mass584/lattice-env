# verilog-primitive-modules

波形シミュレーション環境はMAC
Lattice Radiantの動作環境はubuntu18.04を前提としています


1. gtkwaveインストール

```
brew tap homebrew/cask
brew cask install gtkwave
```

以下のエラーメッセージが出る場合がある

```
Error: Checksum for Cask 'gtkwave' does not match.

Expected: 8bbbde8d6cd98e1cc8e3adbc5d27fda111feb05ec08855ed25930cde928a161c
Actual:   8127f909d58cc114c67ea3a703fa5cf578d5db47874530426935597eedf942b4
File:     /Users/masugata/Library/Caches/Homebrew/downloads/65d2bf8e005d8a33e66110b9bdaa4a1b95f5276c302df78360988884537d6c1d--gtkwave.zip

To retry an incomplete download, remove the file above.
```

この場合はsha256のchecksum値を変更する必要がある

```
brew cask edit gtkwave
```

再度インストールを実行

```
brew cask install gtkwave
```


2. icarus-verilogインストール

```
brew install icarus-verilog
```


3. 波形シミュレーション

```
cd camera64x64_dummy
make
./sim_top
open sim_top.vcd
```


4. lattice radiantのインストール

以下より本体パッケージとライセンスファイルをダウンロードします。
対応OSはRHELとなっていますが、ubuntuでも動作します。
http://www.latticesemi.com/latticeradiant

インストール方法はInstallation Guidesを参照してください。


5. コンフィグレーションROMデータ作成

radiant起動をする。

```
radiant &
```

プロジェクトファイル camera64x64_dummy.rdf を読み込み、コンパイルを実行してください。
以下のコンフィグレーションROMデータファイルが生成されます。

```
project/impl_1/camera64x64_dummy_impl_1.bin
```

