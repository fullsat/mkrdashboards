MackerelのダッシュボードをぽちぽちGUIで作っていられないのでYamlでパラメータ指定したらダッシュボードを生成してくれるようにする

I hate to create dashboards by GUI, so I make this tool which can be created with yaml file.

# どういうダッシュボードができるか

* Mackerelのカスタムダッシュボード
* 時間軸が可変、6時間、3日間、1ヶ月の4列のダッシュボード
* 表示させるグラフは自分で指定できる
* ロールで一括表示したくてもホストにしかメトリクスが存在しない場合はロールを指定して1行1行表示していく
