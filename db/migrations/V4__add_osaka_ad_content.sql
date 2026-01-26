-- V4__add_osaka_ad_content.sql
-- Flyway Migration: 大阪駅周辺施設・広告データ追加

-- まず大阪駅のマップノードを追加
INSERT INTO map_node (node_name, coord_x, coord_y, attribute, adj_nodes) VALUES
('中央口改札', 50.0, 50.0, 1, '2,3,4'),
('御堂筋口改札', 40.0, 50.0, 1, '1,5'),
('桜橋口改札', 60.0, 50.0, 1, '1,6'),
('ルクア前', 50.0, 60.0, 0, '1,7,8'),
('阪急百貨店前', 35.0, 55.0, 0, '2'),
('ヒルトン方面', 65.0, 55.0, 0, '3'),
('グランフロント入口', 50.0, 70.0, 0, '4'),
('エキマルシェ', 55.0, 55.0, 3, '4');

-- 飲食店
INSERT INTO ad_content (shop_name, category, file_path, description, business_hours, map_node_id) VALUES
('一蘭 大阪駅店', 'ラーメン', '/ads/ichiran.jpg', '天然とんこつラーメン専門店。濃厚な豚骨スープと秘伝のタレが自慢。一人一人仕切られた「味集中カウンター」で集中して味わえます。', '10:00-23:00', (SELECT node_id FROM map_node WHERE node_name = 'エキマルシェ')),
('神座 ルクア大阪店', 'ラーメン', '/ads/kamukura.jpg', '大阪発祥の白菜たっぷりラーメン。あっさりながらコクのあるスープが特徴。', '11:00-22:00', (SELECT node_id FROM map_node WHERE node_name = 'ルクア前')),
('蓬莱551 大阪駅店', '中華', '/ads/horai551.jpg', '大阪名物の豚まんで有名。ジューシーな餡と薄皮が特徴。お土産にも最適。', '09:00-21:00', (SELECT node_id FROM map_node WHERE node_name = '中央口改札')),
('くくる エキマルシェ店', 'たこ焼き', '/ads/kukuru.jpg', '大阪名物たこ焼き。外はカリッと中はトロトロ。明石焼きも人気。', '10:00-22:00', (SELECT node_id FROM map_node WHERE node_name = 'エキマルシェ')),
('スターバックス 大阪駅中央口店', 'カフェ', '/ads/starbucks.jpg', '改札すぐのカフェ。待ち合わせにも便利。電源・Wi-Fiあり。', '07:00-22:00', (SELECT node_id FROM map_node WHERE node_name = '中央口改札')),
('ビアードパパ エキマルシェ店', 'スイーツ', '/ads/beardpapa.jpg', '焼きたてシュークリーム専門店。サクサクの皮と濃厚カスタードが人気。', '10:00-21:00', (SELECT node_id FROM map_node WHERE node_name = 'エキマルシェ'));

-- お土産・ショッピング
INSERT INTO ad_content (shop_name, category, file_path, description, business_hours, map_node_id) VALUES
('りくろーおじさんの店', 'お土産', '/ads/rikuro.jpg', '大阪名物チーズケーキ。ふわふわでとろける食感。焼きたても購入可。', '09:00-21:00', (SELECT node_id FROM map_node WHERE node_name = '中央口改札')),
('グランカルビー', 'お土産', '/ads/grandcalbee.jpg', 'カルビーの高級ポテトチップス専門店。ここでしか買えない限定フレーバーあり。', '10:00-21:00', (SELECT node_id FROM map_node WHERE node_name = 'ルクア前')),
('阪神梅田本店 スナックパーク', 'お土産', '/ads/hanshin.jpg', '阪神名物いか焼き、その他大阪グルメが集結。食べ歩きにも最適。', '10:00-20:00', (SELECT node_id FROM map_node WHERE node_name = '御堂筋口改札')),
('アントレマルシェ', 'お土産', '/ads/entre.jpg', '改札外のお土産ショップ。大阪みやげが一堂に揃う。駅弁も販売。', '06:30-22:00', (SELECT node_id FROM map_node WHERE node_name = '中央口改札'));

-- 宿泊施設
INSERT INTO ad_content (shop_name, category, file_path, description, business_hours, map_node_id) VALUES
('ヒルトン大阪', 'ホテル', '/ads/hilton.jpg', '大阪駅直結の高級ホテル。桜橋口から徒歩3分。レストラン・スパ完備。', '24時間', (SELECT node_id FROM map_node WHERE node_name = 'ヒルトン方面')),
('グランヴィア大阪', 'ホテル', '/ads/granvia.jpg', 'JR西日本直営ホテル。大阪駅中央口直結。ビジネス・観光に便利。', '24時間', (SELECT node_id FROM map_node WHERE node_name = '中央口改札')),
('インターコンチネンタル大阪', 'ホテル', '/ads/intercontinental.jpg', 'グランフロント大阪内の高級ホテル。大阪駅から徒歩5分。', '24時間', (SELECT node_id FROM map_node WHERE node_name = 'グランフロント入口'));

-- サービス・その他
INSERT INTO ad_content (shop_name, category, file_path, description, business_hours, map_node_id) VALUES
('セブン銀行ATM 大阪駅', 'ATM', '/ads/sevenbank.jpg', '24時間利用可能。海外カード対応。中央口改札外。', '24時間', (SELECT node_id FROM map_node WHERE node_name = '中央口改札')),
('JR西日本みどりの窓口', 'サービス', '/ads/midori.jpg', '新幹線・特急券の購入、きっぷの変更など。中央口改札横。', '05:30-23:00', (SELECT node_id FROM map_node WHERE node_name = '中央口改札'));
