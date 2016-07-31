# ogp

※[aozorahack hackathon #1(2016/07/30-31)](http://aozorahack.connpass.com/event/33921/)の成果物です。

青空文庫の図書カードに[OGP](http://ogp.me/)を設定しました。 これにより、FacebookやTwitterでシェアした時などに表示される情報を改善できます。

OGPやOGPを使ってシェアされたものの例は[Facebookのウェブ管理者向けシェア機能ガイド](https://developers.facebook.com/docs/sharing/webmasters)や[Twitter Cardの説明ページ](https://dev.twitter.com/ja/cards/overview)を参照してください。

## OGPの導入イメージ

図書カード：No.5の[あいびき](http://www.aozora.gr.jp/cards/000005/card5.html)にOGPを設定してみました。

添付している画像は、Facebookのシェアボタンを押した時とのスクリーンショットです。 [Open Graph Debugger](https://developers.facebook.com/tools/debug/)(閲覧にはログインが必要)を使って取得しています。Twitterでも同様の表示になります。

作者情報の表記は、[XHTML版](http://www.aozora.gr.jp/cards/000005/files/5_21310.html)のtitleタグの内容を参考にしています。

| スクリーンショット | HTML |
| --- | --- |
| ![card5.htmlのFacebookのシェア画像](facebook_link_preview/card5_image.png) | [card5.html(オリジナル)](https://aozorahack.github.io/ogp/cards/000005/card5.html) |
| ![card5_1.htmlのFacebookのシェア画像](facebook_link_preview/card5_1_image.png) | [card5_1.html(OGPに、タイトルと作者情報を含めたもの) ](https://aozorahack.github.io/ogp/cards/000005/card5_1.html) |
| ![card5_2.htmlのFacebookのシェア画像](facebook_link_preview/card5_2_image.png) | [card5_2.html(OGPに、タイトルと作者情報と本文の冒頭を含めたもの)](https://aozorahack.github.io/ogp/cards/000005/card5_2.html) |

## OGP用に本文の冒頭を抽出し、OGPを埋め込む方法

TBD
