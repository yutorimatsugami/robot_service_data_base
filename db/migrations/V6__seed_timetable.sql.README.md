# V6__seed_timetable.sql

時刻表データを投入するマイグレーションファイルです。

## 注意

データの再配布を避けるため、このファイルはGitリポジトリに含めていません。
ローカル環境で別途用意してください。

## SQLの形式

```sql
INSERT INTO train_timetable (station_name, osaka_departure_time, osaka_platform, train_type, destination, direction, arrival_status) VALUES
('駅名', '05:00', '8', '普通', '行先', '方面', '○'),
...;
```
