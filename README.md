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
├── docker-compose.yml    # Docker定義
├── .env.example          # 環境変数テンプレート
├── .env                  # 環境変数 (Git管理外)
├── .gitignore
├── README.md
├── start.sh              # Linux/macOS用起動スクリプト
├── start.ps1             # Windows用起動スクリプト
└── db/
    ├── init/             # 初期化SQL
    │   ├── 01_schema.sql # テーブル定義
    │   └── 02_seeds.sql  # 初期データ
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
