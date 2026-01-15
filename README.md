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
git clone https://github.com/YOUR_USERNAME/robot_service_data_base.git
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

### 3. Access / アクセス

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
    │   └── V2__insert_seeds.sql
    ├── init/             # 初期化SQL (レガシー/参照用)
    │   ├── 01_schema.sql
    │   └── 02_seeds.sql
    └── data/             # DBデータ (Git管理外)
```

---

## 🗄️ Database Schema / データベース構成

| テーブル | 説明 |
|---------|------|
| `robot_mst` | ロボット管理（ID, ステータス, 位置） |
| `map_node` | マップノード（駅構内の場所定義） |
| `ad_content` | 広告・周辺施設情報 |
| `faq_responses` | 定型回答データ |
| `crowd_log` | 混雑ログ |

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
   V3__add_new_column.sql   # バージョン番号を付ける
   ```

2. ファイル命名規則：
   - `V{バージョン}__{説明}.sql`
   - 例: `V3__add_floor_to_map_node.sql`

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
rm -rf db/data
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

-- 特定ステータスのロボットを検索
SELECT * FROM robot_mst WHERE status = 'active';

-- マップノード一覧を取得
SELECT * FROM map_node ORDER BY node_id;

-- テーブル結合の例
SELECT r.robot_id, r.name, m.node_name 
FROM robot_mst r 
JOIN map_node m ON r.current_node_id = m.node_id;
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
| `db/init/` | レガシー初期化SQL（参照用） |

#### 変更の手順

1. **新しいマイグレーションファイルを作成**
   ```bash
   # ファイル命名規則: V{バージョン}__{説明}.sql
   # 例: カラム追加
   touch db/migrations/V3__add_floor_to_map_node.sql
   ```

2. **SQLを記述**
   ```sql
   -- V3__add_floor_to_map_node.sql
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
