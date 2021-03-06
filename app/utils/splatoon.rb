module Splatoon

  RULES = {
      'area':     {'ja': 'ガチエリア', 'en': 'Splat Zones'},
      'hoko':     {'ja': 'ガチホコバトル', 'en': 'Rainmaker'},
      'yagura':   {'ja': 'ガチヤグラ', 'en': 'Tower Control'},
      'nawabari': {'ja': 'ナワバリバトル', 'en': 'Turf war'},
  }.with_indifferent_access

  STAGES = {
      'arowana':  {'ja': 'アロワナモール', 'en': 'Arowana mall'},
      'bbass':    {'ja': 'Bバスパーク', 'en': 'Blackbelly Skatepark'},
      'dekaline': {'ja': 'デカライン高架下', 'en': 'Urchin Underpass'},
      'hakofugu': {'ja': 'ハコフグ倉庫', 'en': 'Walleye Warehouse'},
      'hirame':   {'ja': 'ヒラメが丘団地', 'en': 'Flounder Heights'},
      'hokke':    {'ja': 'ホッケふ頭', 'en': 'Port Mackerel'},
      'kinmedai': {'ja': 'キンメダイ美術館', 'en': 'Museum Alfonsino'},
      'mahimahi': {'ja': 'マヒマヒリゾート&スパ', 'en': 'Mahi-Mahi Resort'},
      'masaba':   {'ja': 'マサバ海峡大橋', 'en': 'Hammerhead Bridge'},
      'mongara':  {'ja': 'モンガラキャンプ場', 'en': 'Camp Triggerfish'},
      'mozuku':   {'ja': 'モズク農園', 'en': 'Kelp Dome'},
      'negitoro': {'ja': 'ネギトロ炭鉱', 'en': 'Bulefin Depot'},
      'shionome': {'ja': 'シオノメ油田', 'en': 'Saltspray Rig'},
      'tachiuo':  {'ja': 'タチウオパーキング', 'en': 'Moray Towers'},
      'syotturu':  {'ja': 'ショッツル鉱山', 'en': 'Piranha Pit'},
  }.with_indifferent_access

  RESULTS = {
      'win': {'ja': '勝利'},
      'lose': {'ja': '敗北'}
  }.with_indifferent_access
end
