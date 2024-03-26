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
          if event.message['text'] == 'はい' then
            message.push(sticker)
          elsif event.message['text'] == 'いいえ' then
            message.push()
          else
            message.push(confirm_template)
          end
        end
      end
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
    {type: 'text', text: "#{novel[1]['title']}\n\n#{novel[1]['story']}"}
  end

  def narou_api
    uri = URI('https://api.syosetu.com/novelapi/api/')
    params = {
      out: 'json',
      ncode: 'n8920ex',
    }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    novel = JSON.parse(res.body)
    p novel
    {type: 'text', text: "#{novel[1]['title']}\n\n最終更新：#{novel[1]['general_lastup']}"}
  end

  def confirm_template
    {
      "type": "template",
      "altText": "これは確認テンプレートです",
      "template": {
        "type": "confirm",
        "text": "本当に？",
        "actions": [
          {
            "type": "message",
            "label": "はい",
            "text": "はい"
          },
          {
            "type": "message",
            "label": "いいえ",
            "text": "いいえ"
          }
        ]
      }
    }
  end

  def 
  
  def runteq_quiz_language
    {
      "type": "template",
      "altText": "ランテックで学ぶメインの言語は？",
      "template": {
        "type": "confirm",
        "text": "ランテックで学ぶメインの言語は？",
        "actions": [
          {
            "type": "message",
            "label": "Ruby",
            "text": "Ruby"
          },
          {
            "type": "message",
            "label": "いいえ",
            "text": "いいえ"
          }
        ]
      }
    }
  end

  def sticker
    {
      "type": "sticker",
      "packageId": "11537",
      "stickerId": "52002734"
    }
  end

  def runteq_quiz_runteq
  end

  def button_template
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
        "type": "buttons",
        "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
        "imageAspectRatio": "rectangle",
        "imageSize": "cover",
        "imageBackgroundColor": "#FFFFFF",
        "title": "Menu",
        "text": "Please select",
        "defaultAction": {
          "type": "uri",
          "label": "View detail",
          "uri": "http://example.com/page/123"
        },
        "actions": [
          {
            "type": "postback",
            "label": "Ruby",
            "data": "action=correct&quizid=1"
          },
          {
            "type": "postback",
            "label": "JS",
            "data": "action=incorrect&quizid=1"
          },
          {
            "type": "uri",
            "label": "View detail",
            "uri": "http://example.com/page/123"
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