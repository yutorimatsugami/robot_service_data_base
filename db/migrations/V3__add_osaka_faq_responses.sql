-- V3__add_osaka_faq_responses.sql
-- Flyway Migration: 大阪駅向け定型回答データ追加

-- 乗り換え・路線案内
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('TRAIN_LINE_INFO', '路線,何線,電車,乗り換え', '大阪駅には、JR神戸線・JR京都線・JR宝塚線・大阪環状線・JR東西線が乗り入れています。どの路線をお探しですか？', 'navigation'),
('SHINKANSEN', '新幹線,東京,名古屋', '新幹線は新大阪駅からご乗車いただけます。大阪駅から新大阪駅へはJR京都線で約4分です。', 'navigation'),
('LOOP_LINE', '環状線,大阪環状線,USJ,ユニバ', '大阪環状線は1番・2番ホームです。USJ（ユニバーサル・スタジオ・ジャパン）へは大阪環状線でユニバーサルシティ駅まで約11分です。', 'navigation'),
('KOBE_LINE', '神戸,三ノ宮,姫路', 'JR神戸線は5番・6番ホームです。三ノ宮駅まで約21分、姫路駅まで約1時間です。', 'navigation'),
('KYOTO_LINE', '京都,高槻', 'JR京都線は7番・8番ホームです。新快速にご乗車ください。京都駅まで約30分です。', 'navigation'),
('NAMBA', '難波,なんば,ミナミ', '難波へはJR難波駅が便利です。大阪環状線で今宮駅乗り換え、またはJR東西線で北新地駅から徒歩で南下できます。', 'navigation');

-- ホーム・出口案内
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('PLATFORM_INFO', 'ホーム,何番,乗り場', '1・2番ホームが大阪環状線、3・4番ホームがJR東西線、5・6番ホームがJR神戸線、7・8番ホームがJR京都線・JR宝塚線です。', 'navigation'),
('CENTRAL_EXIT', '中央口,中央改札,メイン', '中央口は駅の中央部にあり、グランフロント大阪や阪急百貨店へのアクセスに便利です。', 'navigation'),
('MIDOSUJI_EXIT', '御堂筋口,御堂筋,阪急', '御堂筋口を出ると、阪急百貨店・阪神百貨店・地下鉄御堂筋線梅田駅への連絡通路があります。', 'navigation'),
('SAKURABASHI_EXIT', '桜橋口,西梅田', '桜橋口は西側の出口で、ヒルトン大阪やハービスENTへのアクセスに便利です。', 'navigation');

-- 施設案内
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('TOILET', 'トイレ,お手洗い,化粧室', 'トイレは各改札内外にございます。中央口改札内、御堂筋口改札内、桜橋口付近にあります。', 'facility'),
('LOCKER', 'コインロッカー,ロッカー,荷物,預', 'コインロッカーは中央口、御堂筋口、桜橋口付近にございます。大型荷物用もあります。', 'facility'),
('ELEVATOR', 'エレベーター,バリアフリー,車椅子', 'エレベーターは各ホームに設置されています。車椅子の方は駅員にお申し付けください。', 'facility'),
('ATM', 'ATM,現金,お金,銀行', 'ATMは中央口改札外、御堂筋口改札外にございます。', 'facility'),
('GRANFRONT', 'グランフロント,グラン', 'グランフロント大阪へは中央口を出て北側へお進みください。徒歩約3分です。', 'facility'),
('LUCUA', 'ルクア,LUCUA', 'LUCUA（ルクア）は中央口を出てすぐです。LUCUA 1100とLUCUAがあります。', 'facility');

-- 飲食・お土産
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('FOOD_GENERAL', '食事,ご飯,ランチ,ディナー,レストラン', '大阪駅周辺には多くの飲食店がございます。ルクア、グランフロント、大丸梅田店などにレストラン街があります。詳しくお探しの料理はありますか？', 'food'),
('RAMEN', 'ラーメン,らーめん', 'ラーメン店は駅ナカの「エキマルシェ大阪」や、ルクア地下1階にございます。', 'food'),
('TAKOYAKI', 'たこ焼き,たこやき,粉もん', '大阪名物のたこ焼きは、阪神百貨店地下1階の「いか焼き・たこ焼きコーナー」が有名です。', 'food'),
('SOUVENIR', 'お土産,おみやげ,みやげ', 'お土産は中央口改札内の「エキマルシェ大阪」、改札外の「アントレマルシェ」が便利です。', 'shopping'),
('EKIBEN', '駅弁,弁当', '駅弁は中央口改札内の「駅弁屋」でお買い求めいただけます。', 'food');

-- 緊急・サポート
INSERT INTO faq_responses (intent_key, trigger_keywords, response_text, category) VALUES
('LOST_ITEM', '落とし物,忘れ物,なくした', '落とし物・忘れ物は中央口改札横の「お忘れ物承り所」へお問い合わせください。', 'emergency'),
('STAFF_CALL', '駅員,スタッフ,人を呼んで', '駅員をお呼びしますか？少々お待ちください。', 'emergency'),
('EMERGENCY', '緊急,事故,気分が悪い,体調', '緊急の場合は最寄りの駅員にお声がけいただくか、緊急通報ボタンをお使いください。', 'emergency');
