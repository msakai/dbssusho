README.txt

Susho's Filters for Dibas32
Version 0.30


0. はじめに

    このソフトウェアはDibas32 Ver1.04用に約30種の機能を追加するためのプラグイン
    です。


1. 著作権／使用条件

     本ライブラリはフリー・ソフトウェアです。あなたは、Free Software
     Foundation が公表したGNU ライブラリ一般公有使用許諾の第2版或いはそ
     れ以降の各版のいずれかを選択し、その版が定める条項の許で本ライブラ
     リを再配布または変更することができます。
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

     本ライブラリは有用とは思いますが、配布にあたっては、市場性及び特
     定目的適合性についての暗黙の保証を含めて、いかなる保証も行ないま
     せん。詳細についてはGNU ライブラリ一般公有使用許諾書をお読みください。
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.


3. インストール方法

    Susho.f32をDibas32をインストールしたディレクトリに置いて下さい。


4. アンインストール方法

    インストールしたSusho.f32を削除して下さい。


5. 連絡先

    e-mail ZVM01052@nifty.ne.jp


6. 謝辞

    すばらしいソフトウェアとプラグイン仕様を作成されたねたろ氏、
    すばらしいクラスTNKDibを作成された中村拓男氏に感謝します。


7.参考文献

    C Magazine 1998年7月号
    C Magazine 1998年10月号
    C Magazine 1998年11月号
    Delphiテクニックマスター集中講義
    実践Delphiコンポーネントプログラミング
    写真工業別冊 イメージング Part 1


8. 問題点

    プレビューボタンを押した後の処理中にパラメーターを変更すると予期しない結果
    を引き起こすことがあります。プラグイン側ではどうしようもない事なので、とり
    あえず注意して下さい。 

    ちょっとイレギュラーなフォントの取得方法を行っているので、異なったバージョ
    ンのDibasでの動作は予測できません。ペンの設定用ダイアログを開いて、かつhwnd
    からフォントが取得できない場合、以下のようにしてフォントを取得しています。
      SendMessage(GetParent(hwnd), DBSM_GET_TOOLFONT, 0, 0L); 


9. 更新履歴

    1998年12月31日 v0.10(α)　初公開バージョン
    1999年1月29日  v0.20
      ・「単色効果」フィルタの作成
      ・「パレット適用」の実装の変更
      ・「RGBシフト」フィルタの作成
      ・プレビュー中にプレビューボタンを押すと暴走する不具合を発生しにくくした
      ・ガラス処理のダイアログの「Vertical」が「Vertivcal」となっていたのを修正
      ・ガラス処理のパラメーターに「Size」を追加
      ・「サイズ変更」の「領域内平均法」を削除
      ・「減色」の「パレット適用」を削除
      ・全体的なユーザーインターフェイスの調整
      ・バージョン情報の追加
  1999年7月24日 v0.30
      ・ライセンスをLGPL変更
      ・使用するNkDibを0.65版に更新。
      ・幾つかの機能の追加と削除
      ・内部処理の変更いくつか
