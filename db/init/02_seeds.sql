-- 02_seeds.sql

-- マップノード
INSERT INTO map_node (node_name, coord_x, coord_y, attribute, adj_nodes) VALUES
('北口改札', 10.0, 50.0, 1, '2,5'),
('中央通路A', 15.0, 50.0, 0, '1,3,6'),
('お土産屋エリア', 20.0, 60.0, 3, '2,4'),
('待機場所1', 25.0, 60.0, 4, '3'),
('トイレ前', 10.0, 40.0, 0, '1'),
('3番ホーム階段', 20.0, 40.0, 2, '2');

-- ロボット
INSERT INTO robot_mst (robot_id, status, loc_x, loc_y, battery_level) VALUES
('ROBOT_01', 0, 25.0, 60.0, 85),
('ROBOT_02', 1, 15.0, 50.0, 60);

-- 周辺施設・広告
INSERT INTO ad_content (shop_name, category, file_path, description, business_hours, map_node_id) VALUES
('東京バナナ屋', 'お土産', '/ads/banana.jpg', '東京の定番お土産。期間限定味もあります。', '09:00-21:00', 3),
('駅弁屋 祭', '飲食店', '/ads/ekiben.jpg', '全国の駅弁を取り揃えています。', '06:00-23:00', 3),
('NewDays', 'コンビニ', '/ads/newdays.jpg', '駅ナカコンビニ。', '05:00-24:00', 2);

-- 定型回答
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('GREETING', 'こんにちは,おはよう,こんばんは', 'こんにちは。私は案内ロボットです。何かお困りですか？', 'common'),
('LOST_CHILD', '迷子,子供', '迷子のお呼び出しですね。お近くの駅員にお繋ぎしますか？', 'emergency'),
('TICKET_GATE', '改札,出口', '改札はあちらです。ご案内しますか？', 'navigation'),
('WIFI_INFO', 'Wi-Fi,ネット', '駅構内では無料Wi-Fi「STATION_FREE」がご利用いただけます。', 'service');
