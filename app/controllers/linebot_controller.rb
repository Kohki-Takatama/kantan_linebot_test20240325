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
          message.push(next_quiz(0))
        end
      when Line::Bot::Event::Postback
        data = Rack::Utils.parse_nested_query(event['postback']['data'])
        case data['action']
        when 'correct'
          message.push(sticker_correct)
          message.push(next_quiz(data['quizid'].to_i))
        when 'incorrect'
          message.push(sticker_incorrect)
          message.push(next_quiz(data['quizid'].to_i - 1))
        end
      end
      client.reply_message(event['replyToken'], message)
    end
  end

  private

  def next_quiz(quizid)
    p "----------"
    p quizid
    p "----------"
    case quizid
    when 0
      quiz_runteq_language
    when 1
      quiz_runteq_spelling
    when 2
      {'type': 'text', 'text': '全問正解！'}
    else
      quiz_runteq_language
    end
  end

  def quiz_runteq_language
    {
      "type": "template",
      "altText": "第一問：ランテックで学ぶメインの言語は？",
      "template": {
        "type": "confirm",
        "text": "第一問：ランテックで学ぶメインの言語は？",
        "actions": [
          {
            "type": "postback",
            "label": "Ruby",
            "data": "action=correct&quizid=1"
          },
          {
            "type": "postback",
            "label": "Java",
            "data": "action=incorrect&quizid=1"
          }
        ]
      }
    }
  end

  def quiz_runteq_spelling
    {
      "type": "template",
      "altText": "第二問：ランテックのつづりは？",
      "template": {
        "type": "confirm",
        "text": "第二問：ランテックのつづりは？",
        "actions": [
          {
            "type": "postback",
            "label": "RANTEK",
            "data": "action=incorrect&quizid=2"
          },
          {
            "type": "postback",
            "label": "RUNTEQ",
            "data": "action=correct&quizid=2"
          }
        ]
      }
    }
  end

  def sticker_correct
    {
      "type": "sticker",
      "packageId": "11537",
      "stickerId": "52002734"
    }
  end

  def sticker_incorrect
    {
      'type': 'sticker',
      'packageId': '789',
      'stickerId': '10881'
    }
  end


  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end