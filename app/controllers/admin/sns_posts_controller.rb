class Admin::SnsPostsController < ApplicationController
  def index
  end

  def generate
    dog_name = params[:dog_name].presence || "わんちゃん"
    shop_name = params[:shop_name]

    header = shop_name.present? ? "bonne puppy#{shop_name}です" : "bonne puppyです"

    month = params[:month].to_i
    day = params[:day].to_i
    post_type = params[:post_type]

    if post_type == "announcement"
      m = month > 0 ? month : Time.current.month
      d = day > 0 ? day : 1

      date = Date.new(Date.today.year, m, d)
      wday = %w[日 月 火 水 木 金 土][date.wday]

      @idea = "#{m}月の休園日のお知らせです"

      @caption = <<~TEXT
        #{header}😌✨
        #{m}月の休園日のお知らせです📣
        #{m}月#{d}日（#{wday}）は店舗清掃・店舗ミーティングの為、【幼稚園・保育園】はお休みとなります🙇‍♀️
        【一時預かり・ホテル】のご予約は受け付けておりますのでお気軽にご連絡下さいませ🌟
        ご不便をおかけいたしますが宜しくお願いいたします🙇‍♀️
      TEXT

    elsif post_type == "best_shot"
      @idea = "今週のベストショット"

      @caption = <<~TEXT
        今週のベストショット📸✨

        bonne puppy#{shop_name}です😌✨
        今週もたくさんの園児さんが登園してくれました🐾
        また来週も元気いっぱいな園児さん達にお会いできるのを楽しみにお待ちしております🎶
      TEXT

    else
      @idea = ideas(dog_name, month).sample
      base_caption = captions(dog_name, params[:tone]).sample

      @caption = "bonne puppy#{shop_name}です\n\n#{@idea}\n\n#{base_caption}"
    end

    @hashtags = hashtags(shop_name)

    render :index
  end

  helper_method :shops

  def shops
    SHOPS
  end

    SHOPS = {
    "弁天町店" => { area_tags: [ "#弁天町犬", "#弁天町ペット", "#弁天町ドッグ" ] },
    "森ノ宮店" => { area_tags: [ "#森ノ宮犬", "#森ノ宮ペット", "#森ノ宮ドッグ" ] },
    "心斎橋店" => { area_tags: [ "#心斎橋犬", "#心斎橋ペット", "#心斎橋ドッグ" ] },
    "北浜店"   => { area_tags: [ "#北浜犬", "#北浜ペット", "#北浜ドッグ" ] },
    "天満店"   => { area_tags: [ "#天満犬", "#天満ペット", "#天満ドッグ" ] },
    "立売堀店" => { area_tags: [ "#立売堀犬", "#立売堀ペット", "#立売堀ドッグ" ] }
  }.freeze

  private

  def ideas(dog_name, month)
    name = dog_name.presence || "園児さん"

    [
      "今日の園児さんの様子をご紹介",
      "園児さんのリラックスタイム",
      "園児さんの可愛い瞬間"
    ]
  end

  def captions(dog_name, tone)
    name = dog_name.presence || "わんちゃん"

    case tone
    when "cute"
      [
        "#{name}が来てくれました🐶💕とっても可愛くて癒されました✨",
        "#{name}、本日も元気いっぱいでした🐾楽しく過ごしてくれました🎶",
        "#{name}の可愛い姿にスタッフもメロメロです😍✨",
        "#{name}、今日もニコニコ笑顔でした😊🐾"
      ]
    when "sales"
      [
        "#{name}ご利用中です🐾一時預かり・ホテル受付中です✨お気軽にご連絡ください📩",
        "#{name}が楽しく過ごしています🐶現在ご予約受付中です✨",
        "#{name}も安心して過ごしています😊ご利用お待ちしております🐾"
      ]
    else # politea
      [
        "#{name}がご来店されました。穏やかに過ごされています。",
        "#{name}、本日も落ち着いて過ごしていただいております。",
        "#{name}、安心して過ごしてくれています。"
      ]
    end
  end

  def hashtags(shop_name)
  fixed = [
    "#bonnepuppy",
    "#ボンパピ"
    # "#ボンパピ#{shop_name}"
  ]
  fixed << "#ボンパピ#{shop_name}" if shop_name.present?

  common = [
    "#犬の幼稚園",
    "#犬ホテル",
    "#一時預かり"
  ]

  area_tags = SHOPS.dig(shop_name, :area_tags) || []

  optional = [
    "#犬好きさんと繋がりたい",
      "#犬のいる暮らし",
      "#わんこ",
      "#犬スタグラム",
      "#doglife",
      "#いぬすたぐらむ",
      "#犬好き",
      "#犬好きな人と繋がりたい",
      "#ペットホテル",
      "#ドッグライフ",
      "#犬の日常",
      "#dogstagram",
      "#ふわもこ部",
      "#愛犬",
      "#犬との生活"
  ]

  random_tags = (common + area_tags + optional).sample(5)

  (fixed + random_tags).uniq
  end
end
