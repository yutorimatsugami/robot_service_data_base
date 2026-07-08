# V6__seed_timetable.sql

時刻表データを投入するマイグレーションファイルです。

## データの生成方法（2026-07-08〜）

以前はJR西日本の公式サイトから手動でコピーした実在の時刻表データを投入していましたが、
再配布・法的位置づけの問題があるため、**完全に自動生成した架空のダイヤ**に置き換えました。

```
python3 db/tools/generate_seed.py [seed]
```

を実行すると `db/tools/station_topology.json`（駅名・方面・行き先の組み合わせという地理的事実のみを
保持したデータ）を元に、発車時刻・番線・列車種別を疑似乱数で新規生成し、このファイルを再生成します。
実在の時刻表を複製・転記したものではありません。デフォルトのseed値は固定なので、同じ内容が再現されます。

## 注意

このファイル自体は（自動生成物のため実質いつでも再生成可能なことと、サイズが大きいことから）
引き続きGitリポジトリには含めていません。`db/tools/generate_seed.py` を実行してローカルで
生成してください。生成元の `db/tools/station_topology.json` は駅名・方面情報のみでダイヤの実データを
含まないため、Git管理下に置いています。

## SQLの形式

```sql
INSERT INTO train_timetable (station_name, osaka_departure_time, osaka_platform, train_type, destination, direction, arrival_status) VALUES
('駅名', '05:00', '8', '普通', '行先', '方面', '○'),
...;
```
