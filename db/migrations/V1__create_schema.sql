-- V1__create_schema.sql
-- Flyway Migration: 初期スキーマ作成

-- マップノードテーブル
CREATE TABLE map_node (
    node_id SERIAL PRIMARY KEY,
    node_name VARCHAR(50) NOT NULL,
    coord_x FLOAT NOT NULL,
    coord_y FLOAT NOT NULL,
    attribute INT NOT NULL, -- 0:通路, 1:改札, 2:階段/エレベータ, 3:店舗, 4:待機場所
    adj_nodes VARCHAR(255)
);

-- ロボット管理テーブル
CREATE TABLE robot_mst (
    robot_id VARCHAR(10) PRIMARY KEY,
    status INT NOT NULL DEFAULT 0, -- 0:待機(定位置), 1:巡回, 2:案内中, 3:遠隔通話中, 9:エラー
    loc_x FLOAT,
    loc_y FLOAT,
    battery_level INT DEFAULT 100
);

-- 混雑状況履歴テーブル
CREATE TABLE crowd_log (
    log_id BIGSERIAL PRIMARY KEY,
    camera_id VARCHAR(10) NOT NULL,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    crowd_level INT NOT NULL
);

-- 周辺施設・広告テーブル (拡張版)
CREATE TABLE ad_content (
    ad_id SERIAL PRIMARY KEY,
    shop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    file_path VARCHAR(255),
    description TEXT,
    business_hours VARCHAR(100),
    map_node_id INT REFERENCES map_node(node_id)
);

-- 定型回答テーブル (新規)
CREATE TABLE faq_responses (
    response_id SERIAL PRIMARY KEY,
    intent_key VARCHAR(50) NOT NULL UNIQUE,
    trigger_keywords TEXT,
    response_text TEXT NOT NULL,
    category VARCHAR(50)
);

COMMENT ON COLUMN map_node.attribute IS '0:通路, 1:改札, 2:階段/エレベータ, 3:店舗, 4:待機場所';
COMMENT ON COLUMN robot_mst.status IS '0:待機(定位置), 1:巡回, 2:案内中, 3:遠隔通話中, 9:エラー';
