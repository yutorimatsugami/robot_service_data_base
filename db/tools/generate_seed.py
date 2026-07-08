#!/usr/bin/env python3
"""train_timetable 用のダミー時刻表データを生成し V6__seed_timetable.sql を作り直す。

実在のJR時刻表を複製・転記するものではない。station_topology.json に保持しているのは
「どの駅からどの方面へどの行き先の列車が出ているか」という路線網の位置関係（地理的事実）
のみで、これは以前の手動収集データから抽出したもの。発車時刻・列車種別といった実際の
ダイヤの中身はすべてこのスクリプトが疑似乱数で新規に生成する（早朝/朝ラッシュ/日中/深夜
の時間帯ごとにサイクル(パターンダイヤ)を敷き、密度を変えることでそれらしい体裁にしている
だけで、実在の時刻とは一致しない）。

のりば(番線)のみは例外で、大阪駅の方面別のりば案内という公表事実
（出典: JR西日本 おでかけネット 駅設備情報 大阪駅 https://eki.jr-odekake.net/premises?id=0610130）
に基づき choose_platform() でマッピングしている。これは「事実」として扱ってよい情報であり、
時刻・列車種別・行き先の割り当てとは性質が異なる（大阪駅以外の駅にも便宜上同じ方面別
マッピングを流用しており、他駅の実際ののりば配置と一致するとは限らない）。

再現性のため乱数シードは固定（引数で上書き可）。station_topology.json 自体は
Git管理してよいが、生成後の V6__seed_timetable.sql は引き続き .gitignore 対象とする
（Flywayのローカルマイグレーションとして都度このスクリプトで再生成する運用）。

使い方:
    python3 generate_seed.py [seed]
"""
import json
import random
import sys
from pathlib import Path

TOPOLOGY_PATH = Path(__file__).parent / "station_topology.json"
OUTPUT_PATH = Path(__file__).parent.parent / "migrations" / "V6__seed_timetable.sql"

# 種別ごとの出現に必要な最小行き先数。行き先数が多い方面ほど幹線寄りとみなし、
# 速達種別（快速・新快速・特急）が走る条件を厳しくする。
MIN_DEST_FOR_TYPE = {
    "普通": 1,
    "快速": 2,
    "新快速": 3,
    "特急": 4,
}

# 日中/早朝/深夜で共通して使う15分サイクルのテンプレート（サイクル内オフセット分, 種別）。
# 新快速4本/h・快速4本/h・普通8本/hのイメージ。
CYCLE_TEMPLATE_DAY = [(0, "新快速"), (2, "普通"), (7, "普通"), (8, "快速")]
CYCLE_DAY_LEN = 15

# 深夜(終電帯)用の20分サイクルテンプレート。本数を絞る。
CYCLE_TEMPLATE_NIGHT = [(0, "新快速"), (5, "普通"), (12, "快速"), (15, "普通")]
CYCLE_NIGHT_LEN = 20

# 時間帯境界（0:00からの分数）
EARLY_START_MIN = 5 * 60        # 5:00
RUSH_START_MIN = 7 * 60         # 7:00
DAY_START_MIN = 9 * 60          # 9:00
NIGHT_START_MIN = 22 * 60       # 22:00
NIGHT_END_MIN = 24 * 60 + 30    # 終電は日付またぎ 0:30 まで

# 特急はサイクルダイヤの外で、独立した間隔で終日運行する。
TOKKYU_START_JITTER = 40   # 始発オフセット上限(分)
TOKKYU_INTERVAL = (90, 150)  # 発車間隔レンジ(分)


def sql_escape(s: str) -> str:
    return s.replace("'", "''")


def minutes_to_hhmm(t: int) -> str:
    h = (t // 60) % 24
    m = t % 60
    return f"{h:02d}:{m:02d}"


def choose_platform(rng: random.Random, direction: str, train_type: str) -> str:
    """大阪駅の方面別のりば案内（公表事実）に基づき番線を選ぶ。

    出典: JR西日本 おでかけネット 駅設備情報 大阪駅
    https://eki.jr-odekake.net/premises?id=0610130
    """
    if direction == "三ノ宮・姫路方面":
        return rng.choice(["3", "4", "5", "6"])
    if direction == "新大阪・高槻・京都方面":
        return rng.choice(["7", "8", "9", "10"])
    if direction == "京都・北陸・東海方面":
        return "11" if train_type == "特急" else rng.choice(["7", "8", "9", "10"])
    if direction == "尼崎・宝塚・福知山方面":
        if train_type == "普通":
            return "6" if rng.random() < 0.7 else rng.choice(["3", "4"])
        return rng.choice(["3", "4"])
    if direction == "山陽・福知山・山陰方面":
        return rng.choice(["3", "4"])
    if direction == "京橋・鶴橋方面":
        return "2"
    if direction == "西九条・天王寺・関西空港・和歌山・奈良・ユニバーサルシティ方面":
        return "21" if train_type == "特急" else "1"
    if direction == "新大阪・京都・奈良（まほろば号）方面":
        return "24" if train_type == "特急" else rng.choice(["22", "23"])
    # 未知の方面ラベル（将来のトポロジー拡張向けフォールバック）
    return rng.choice([str(p) for p in range(1, 13)])


def generate_cycle_departures(rng, template, cycle_len, period_start, period_end,
                               destinations, allowed_types):
    """サイクルダイヤ(パターンダイヤ)テンプレートから発車データを生成する。"""
    departures = []
    cycle_start = float(period_start)
    while cycle_start < period_end:
        for offset, train_type in template:
            if train_type not in allowed_types:
                continue
            base_t = cycle_start + offset
            if base_t >= period_end:
                continue
            jitter = rng.randint(-1, 1)
            dep_t = int(round(base_t)) + jitter
            dest = rng.choice(destinations)
            departures.append((dep_t, train_type, dest))
        cycle_start += cycle_len
    return departures


def generate_tokkyu_departures(rng, destinations, period_start, period_end):
    """特急はサイクル外・独立間隔で終日運行する。"""
    departures = []
    t = period_start + rng.randint(0, TOKKYU_START_JITTER)
    lo, hi = TOKKYU_INTERVAL
    while t < period_end:
        dest = rng.choice(destinations)
        departures.append((t, "特急", dest))
        t += rng.randint(lo, hi)
    return departures


def generate_departures_for_direction(rng, destinations):
    """1方面ぶんの一日の発車データ(発車分, 種別, 行き先)のリストを生成する。"""
    allowed_types = {
        train_type
        for train_type, min_dest in MIN_DEST_FOR_TYPE.items()
        if train_type != "特急" and len(destinations) >= min_dest
    }

    # ラッシュ時の運行密度(1.5〜2.0倍)を(駅,方面)ごとに一度だけ決め、
    # 15分サイクルの実効長を短縮することで本数を増やす。
    density = rng.uniform(1.5, 2.0)
    rush_cycle_len = CYCLE_DAY_LEN / density

    # 早朝は日中と同じテンプレートだが、始発が5:00〜5:29台に収まるよう位相をずらす。
    early_phase_shift = rng.randint(0, 29)

    departures = []
    departures += generate_cycle_departures(
        rng, CYCLE_TEMPLATE_DAY, CYCLE_DAY_LEN,
        EARLY_START_MIN + early_phase_shift, RUSH_START_MIN,
        destinations, allowed_types,
    )
    departures += generate_cycle_departures(
        rng, CYCLE_TEMPLATE_DAY, rush_cycle_len,
        RUSH_START_MIN, DAY_START_MIN,
        destinations, allowed_types,
    )
    departures += generate_cycle_departures(
        rng, CYCLE_TEMPLATE_DAY, CYCLE_DAY_LEN,
        DAY_START_MIN, NIGHT_START_MIN,
        destinations, allowed_types,
    )
    departures += generate_cycle_departures(
        rng, CYCLE_TEMPLATE_NIGHT, CYCLE_NIGHT_LEN,
        NIGHT_START_MIN, NIGHT_END_MIN,
        destinations, allowed_types,
    )

    if len(destinations) >= MIN_DEST_FOR_TYPE["特急"]:
        departures += generate_tokkyu_departures(
            rng, destinations, EARLY_START_MIN, NIGHT_END_MIN,
        )

    departures.sort(key=lambda d: d[0])
    return departures


def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 20260708
    rng = random.Random(seed)

    with open(TOPOLOGY_PATH, encoding="utf-8") as f:
        topology = json.load(f)

    rows = []
    for station in sorted(topology.keys()):
        for direction, raw_destinations in topology[station].items():
            # 自駅と同名の行き先（元データ由来の表記ゆれ）は除外する
            destinations = [d for d in raw_destinations if d != station] or raw_destinations

            for t, train_type, dest in generate_departures_for_direction(rng, destinations):
                platform = choose_platform(rng, direction, train_type)
                rows.append((
                    station,
                    minutes_to_hhmm(t),
                    platform,
                    train_type,
                    dest,
                    direction,
                ))

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write("-- Auto-generated seed data for train_timetable (synthetic / non-scraped)\n")
        f.write("-- Generated by db/tools/generate_seed.py -- see V6__seed_timetable.sql.README.md\n")
        f.write(
            "INSERT INTO train_timetable "
            "(station_name, osaka_departure_time, osaka_platform, train_type, destination, direction, arrival_status) VALUES\n"
        )
        lines = [
            "('{}', '{}', '{}', '{}', '{}', '{}', '○')".format(
                sql_escape(station), time_str, platform, sql_escape(train_type),
                sql_escape(dest), sql_escape(direction),
            )
            for station, time_str, platform, train_type, dest, direction in rows
        ]
        f.write(",\n".join(lines))
        f.write(";\n")

    print(f"Generated {len(rows)} rows for {len(topology)} stations -> {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
