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
          message.push(narou_api)
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

  def narou_api
    uri = URI('https://api.syosetu.com/novelapi/api/')
    params = {
      out: 'json',
      ncode: 'n8920ex'
    }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    novel = JSON.parse(res.body)
    {type: 'text', text: "#{novel[1]['title']}\n\n#{novel[1]['story']}"}
  end

  def runteq_quiz_hisaju
  end

  def runteq_quiz_runteq
  end

  def confirm_message
  end

  def image_carousel
  end

  def qiita_trend_api
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end