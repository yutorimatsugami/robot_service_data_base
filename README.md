# Robot Service Database

案内ロボットサービス用のデータベース環境です。Docker Composeで簡単にセットアップできます。

---

## 📋 Requirements / 必要環境

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

### Windows
- Docker Desktop for Windows をインストール
- WSL2 バックエンドを有効化推奨

### Linux / macOS
- Docker Engine と Docker Compose をインストール

---

## 🚀 Quick Start / クイックスタート

### 1. Clone & Setup / クローンとセットアップ

```bash
git clone https://github.com/yutorimatsugami/robot_service_data_base.git
cd robot_service_data_base

# Copy environment template / 環境変数テンプレートをコピー
cp .env.example .env
```

### 2. Start / 起動

**Linux / macOS:**
```bash
./start.sh
```

**Windows (PowerShell):**
```powershell
.\start.ps1
```

**または手動で:**
```bash
docker-compose up -d
```

### 3. 時刻表データの投入 (V6シード生成) / Timetable Seed Generation

`db/migrations/V6__seed_timetable.sql` は `.gitignore` 対象のため、clone直後は**存在しません**。`train_timetable` テーブルは作成されますが、このステップを行わない限り**空のまま**です。`db/tools/station_topology.json`（駅の路線網データ）から `db/tools/generate_seed.py` がダミーの時刻表データを疑似乱数で生成し、`V6__seed_timetable.sql` として書き出します。

```bash
python3 db/tools/generate_seed.py
# 再現性のため乱数シードは固定（引数で上書き可: python3 db/tools/generate_seed.py <seed>）

# 生成後、DBを起動（または起動済みなら再起動）してFlywayに適用させる
docker-compose up -d
docker-compose run --rm flyway info   # V6が適用されたことを確認
```

> **⚠️ 注意**: `V6__seed_timetable.sql` は生成物のためGit管理されません。クリーンな環境でセットアップするたびに、または `station_topology.json` を更新した場合に、このスクリプトを再実行してください。

### 4. Access / アクセス

| サービス | URL | 説明 |
|---------|-----|------|
| **Adminer** | http://localhost:8080 | DB管理画面 |
| **PostgreSQL** | localhost:5432 | 直接接続 |

**Adminer ログイン情報:**
- システム: `PostgreSQL`
- サーバー: `db`
- ユーザー名: `robot_user` (または `.env` で設定した値)
- パスワード: `robot_pass` (または `.env` で設定した値)
- データベース: `robot_service_db`

---

## 📁 Project Structure / プロジェクト構成

```
robot_service_data_base/
├── docker-compose.yml    # Docker定義（Flyway含む）
├── .env.example          # 環境変数テンプレート
├── .env                  # 環境変数 (Git管理外)
├── .gitignore
├── README.md
├── start.sh              # Linux/macOS用起動スクリプト
├── start.ps1             # Windows用起動スクリプト
└── db/
    ├── migrations/       # Flywayマイグレーション (推奨)
    │   ├── V1__create_schema.sql
    │   ├── V2__insert_seeds.sql
    │   ├── V3__add_osaka_faq_responses.sql
    │   ├── V4__add_osaka_ad_content.sql
    │   ├── V5__create_timetable.sql
    │   ├── V6__seed_timetable.sql          # 生成物 (Git管理外、要generate_seed.py実行。上記手順3を参照)
    │   └── V6__seed_timetable.sql.README.md
    ├── init/             # 初期化SQL (レガシー/参照用、V1/V2相当のみ)
    │   ├── 01_schema.sql
    │   └── 02_seeds.sql
    ├── tools/            # シードデータ生成ツール
    │   ├── generate_seed.py
    │   └── station_topology.json
    └── data/             # DBデータ (Git管理外)
```

---

## 🗄️ Database Schema / データベース構成

| テーブル | 説明 |
|---------|------|
| `robot_mst` | ロボット管理（ID, ステータス, 位置） |
| `map_node` | マップノード（駅構内の場所定義） |
| `ad_content` | 広告・周辺施設情報（`map_node_id`は`map_node.node_id`への外部キー） |
| `faq_responses` | 定型回答データ |
| `crowd_log` | 混雑ログ |
| `train_timetable` | 時刻表データ（要V6シード生成、上記参照） |

---

## 🔄 Flyway マイグレーション

Flywayを使用してデータベースのバージョン管理を行います。

### マイグレーションの仕組み

```
起動時: docker-compose up -d
         ↓
Flyway: db/migrations/*.sql を順番に実行
         ↓
DB:     テーブル作成・データ投入（差分のみ適用）
```

### マイグレーション状況の確認

```bash
# 適用済みマイグレーションの確認
docker-compose run --rm flyway info
```

### 新しいマイグレーションの追加

1. `db/migrations/` に新しいファイルを作成
   ```
   V7__add_new_column.sql   # バージョン番号を付ける
   ```

2. ファイル命名規則：
   - `V{バージョン}__{説明}.sql`
   - 例: `V7__add_floor_to_map_node.sql`
   - ⚠️ 既存のマイグレーションと番号が衝突しないよう、`db/migrations/` 内の最新バージョンを確認し、その次の番号を使ってください（本README作成時点の最新は`V6`）。

3. 起動して適用
   ```bash
   docker-compose up -d
   ```

### Flyway コマンド

```bash
# マイグレーション実行
docker-compose run --rm flyway migrate

# 状況確認
docker-compose run --rm flyway info

# 検証（SQLの整合性チェック）
docker-compose run --rm flyway validate

# 修復（失敗したマイグレーションの修復）
docker-compose run --rm flyway repair
```

---


## 🔧 Commands / コマンド

```bash
# 起動
docker-compose up -d

# 停止
docker-compose down

# ログ確認
docker-compose logs -f db

# DBリセット (データ削除)
docker-compose down -v
sudo rm -rf db/data
docker-compose up -d

# DBに直接接続
docker exec -it robot_service_db psql -U robot_user -d robot_service_db
```

---

## 📖 使い方ガイド / Usage Guide

### 1. データの確認・SQL練習（読み取りメイン）

データベースの内容を確認したり、SQLの練習をする場合は以下の方法を使用してください。

#### Adminer (GUI) を使う場合

1. ブラウザで http://localhost:8080 にアクセス
2. ログイン情報を入力してログイン
3. 左側のテーブル一覧からテーブルを選択
4. 「SQLコマンド」でSQLを直接実行可能

**SQLサンプル：**
```sql
-- 全ロボットを取得
SELECT * FROM robot_mst;

-- 特定ステータスのロボットを検索 (statusはINT型: 0:待機, 1:巡回, 2:案内中, 3:遠隔通話中, 9:エラー)
SELECT * FROM robot_mst WHERE status = 1;

-- マップノード一覧を取得
SELECT * FROM map_node ORDER BY node_id;

-- テーブル結合の例（広告・周辺施設情報とマップノードの結合）
SELECT a.shop_name, a.category, m.node_name
FROM ad_content a
JOIN map_node m ON a.map_node_id = m.node_id;
```

#### psql (コマンドライン) を使う場合

```bash
# コンテナ内のpsqlに接続
docker exec -it robot_service_db psql -U robot_user -d robot_service_db

# 接続後に使えるpsqlコマンド
\dt          # テーブル一覧
\d テーブル名  # テーブル構造を表示
\q           # 終了
```

---

### 2. テーブル構造の変更・Git管理（書き込みメイン）

Flywayマイグレーションを使用してスキーマを変更し、Gitで管理します。

#### ファイル構成

| ディレクトリ | 用途 |
|-------------|------|
| `db/migrations/` | Flywayマイグレーションファイル（推奨） |
| `db/init/` | レガシー初期化SQL（参照用、V1/V2相当の内容のみ。V3以降の変更（大阪駅向けFAQ・広告データ、`train_timetable`等）は反映されておらず、スキーマ参照としては古いので注意） |

#### 変更の手順

1. **新しいマイグレーションファイルを作成**
   ```bash
   # ファイル命名規則: V{バージョン}__{説明}.sql
   # 既存の最新マイグレーションの次の番号を使用（`db/migrations/`を確認、本README作成時点の最新は`V6`）
   # 例: カラム追加
   touch db/migrations/V7__add_floor_to_map_node.sql
   ```

2. **SQLを記述**
   ```sql
   -- V7__add_floor_to_map_node.sql
   ALTER TABLE map_node ADD COLUMN floor INT DEFAULT 1;
   ```

3. **起動して自動適用**
   ```bash
   docker-compose up -d
   # Flywayが自動で差分を検出・適用
   ```

4. **適用状況を確認**
   ```bash
   docker-compose run --rm flyway info
   ```

5. **変更をGitにコミット**
   ```bash
   git add db/migrations/
   git commit -m "Add: map_nodeにfloorカラム追加"
   ```

> **💡 ヒント**: Flywayは差分のみ適用するため、DBリセットは不要です。

> **⚠️ 注意**: `db/data/` は `.gitignore` で除外されているため、実データはGit管理されません。

---


### 3. 変更の反映（Docker・Github）

#### ローカルDocker環境への反映

```bash
# 通常: 起動するだけで差分が自動適用
docker-compose up -d

# マイグレーション状況確認
docker-compose run --rm flyway info
```

**完全リセットが必要な場合（データも初期化）：**
```bash
docker-compose down -v
sudo rm -rf db/data
docker-compose up -d
```

#### リモートGithubへの反映

```bash
# 1. 変更をステージング
git add .

# 2. コミット
git commit -m "Add: 変更内容の説明"

# 3. プッシュ
git push origin main
```

**ブランチを使った開発の場合：**
```bash
# 新しいブランチを作成
git checkout -b feature/my-feature

# 変更をコミット
git add .
git commit -m "Add: 新機能の説明"

# プッシュ
git push origin feature/my-feature

# GitHubでPull Requestを作成
```

---

## ⚙️ Configuration / 設定

`.env` ファイルで以下を変更可能：

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `POSTGRES_USER` | robot_user | DBユーザー名 |
| `POSTGRES_PASSWORD` | robot_pass | DBパスワード |
| `POSTGRES_DB` | robot_service_db | DB名 |
| `DB_PORT` | 5432 | PostgreSQLポート |
| `ADMINER_PORT` | 8080 | Adminerポート |

---

## 🤝 Contributing / 貢献

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

MIT License
