MackerelのダッシュボードをぽちぽちGUIで作っていられないのでYamlでパラメータ指定したらダッシュボードを生成してくれるようにする

## 何が作られるか

以下のようなテーブル型のダッシュボードができます

|1時間|1日|1か月|
|:---|:---|:----|
|過去1時間分のレスポンスタイム|過去1日分のレスポンスタイム|過去1か月分のレスポンスタイム|
|過去1時間分のCPU|過去1日分のCPU|過去1か月分のCPU|
|過去1時間分のDiskIO|過去1日分のDiskIO|過去1か月分のDiskIO|

* Mackerelのカスタムダッシュボードが作成されます
* rangesで指定した時間で列のタイムレンジが固定されます
* 表示させるグラフは指定したものを表示します
* ホストにしかメトリクスが存在しない場合はロールに属するホストを１台ずつ表示します

## どのように使うか

```
git clone https://github.com/fullsat/mkrdashboards
cd mkrdashboards
bundle install
export MACKEREL_APIKEY="xxxxxxxxxxxxx" # Write権限が必要
vim conf.d/config.yml # Formatは別記
bundle exec exe/mkrdashboards create --with-delete --config conf.d/config.yml
```

## 設定ファイルのフォーマット

サンプルはconf.d/example.yml

* title => string, ダッシュボードのタイトル
* urlPath => string, urlのパス部分
* memo => string, メモ
* ranges => (nil|([0-9]+)(s|m|h|d|mo|y)), 列のグラフの期間
  * nilは可変
  * ([0-9]+)(s|m|h|d|mo|y)は現時刻から指定した時間の期間
* widget_params => 以下の形式の配列, 指定したグラフの集合
  * type: header
    * markdowns => string, rangesで指定した列数分の文字列配列
  * type: role
    * roleFullname => string, Mackerelの[サービス]:[ロール]
    * name => string, Mackerelのグラフ名
    * isStacked => boolean, グラフを積み上げグラフにするか
  * type: host
    * roleFullname => string, Mackerelの[サービス]:[ロール]
    * name => string, Mackerelのグラフ名
    * isStacked => boolean, グラフを積み上げグラフにするか


## 背景

問題の原因特定に関して、リソース可視化ツールの使い方は以下のように使っていることが多いです。

* ユーザ体験が悪化していた期間の特定
* その期間において各ホストのグラフにおかしなパターンがないか確認
* おかしなパターンがあれば原因の仮設を立てる

あとは仮設が正しいかどうかを繰り返し、間違っていれば再度仮設を立てます。

この仮説と検証の確認の中で、グラフの期間指定のパターンとしては以下のパターンがあることに気づきました

* 短/中/長期的に問題の発生している期間を特定する
* 特定した期間だけを切り取ったグラフを確認する
* 特定した期間のグラフの中で短/中/長期的に見ておかしな値を示しているものを特定する
* これは問題の原因または原因によって引き起こされた異常値として考えられる

この使い方だと、タイムレンジ変更可能なグラフ、短期、中期、長期のグラフが並んでいると便利です。

そのためテーブル型のダッシュボードを作りやすいようなツールが欲しくなりこのツールを作成しました。
