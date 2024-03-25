class LinebotController < ApplicationController
  def callback
    body = request.body.read
    events = client.parse_events_from(body)
    
    events.each do |event|
      message = []
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message.push(parroting(event))
          message.push(runtequn_image)
          message.push(narou_api_ad)
        end
      end
      qiita_trend_api(event)
      client.reply_message(event['replyToken'], message)
    end
  end

  private

  def parroting(event)
    {type: 'text', text: event.message['text']}
  end

  def runtequn_image
    runtequn = 'https://stickershop.line-scdn.net/stickershop/v1/product/18201714/LINEStorePC/main.png?v=1'
    {type: 'image', originalContentUrl: runtequn, previewImageUrl: runtequn}
  end

  def narou_api_ad
    uri = URI('https://api.syosetu.com/novelapi/api/')
    params = {
      out: 'json',
      ncode: 'n8920ex',
    }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    novel = JSON.parse(res.body)
    p novel
    {type: 'text', text: "#{novel[1]['title']}\n\n#{novel[1]['story']}\n\n最終更新：#{novel[1]['general_lastup']}"}
  end

  def runteq_quiz_hisaju

  end

  def runteq_quiz_runteq
  end

  def confirm_message
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
        "type": "confirm",
        "text": "Are you sure?",
        "actions": [
        {
          "type": "message",
          "label": "Yes",
          "text": "yes"
        },
        {
          "type": "message",
          "label": "No",
          "text": "no"
        }
      ]
    }
  }
  end

  def image_carousel
  end

  def qiita_trend_api(event)
    uri = URI('https://qiita-api.vercel.app/api/trend')
    res = Net::HTTP.get_response(uri)
    articles = JSON.parse(res.body)
    message = []
    # トレンド上位5記事のみ抽出
    5.times {|i|
      hash = {}
      hash[:type] = "text"
      hash[:text] = response[i]["node"]["linkUrl"]
      message.push(hash)
    }
    client.reply_message(event['replyToken'],  message)
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end