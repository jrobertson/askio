#!/usr/bin/env ruby

# file: askio.rb

require 'time'
require 'rest-client'



class AskIO
  using ColouredText

  attr_reader :invocation, :utterances

  def initialize(manifest, model, debug: false, userid: nil, 
                 deviceid: nil, appid: nil, modelid: nil)

    @debug, @userid, @deviceid, @appid = debug, userid, deviceid, appid
    @modelid = modelid
    
    @locale = manifest['manifest']['publishingInformation']['locales']\
        .keys.first
    puts '@locale: ' + @locale.inspect if @debug
    
    @invocation = model['interactionModel']['languageModel']['invocationName']
    
    @utterances = model['interactionModel']['languageModel']\
                                        ['intents'].inject({}) do |r, intent|
      intent['samples'].each {|x| r[x.downcase] = intent['name']}
      r
    end

    puts '  debugger::@utterances: ' + @utterances.inspect if @debug

    @endpoint = manifest['manifest']['apis']['custom']['endpoint']['uri']

    puts '  debugger: @endpoint: ' + @endpoint.inspect if @debug
    
  end
  
  def ask(request, &blk)
    
            
    r = @utterances[request]
    puts '  debugger: r: ' + r.inspect if @debug
    puts

    if r then

      puts '  debugger: your intent is to ' + r if @debug

      respond(r, &blk)      

    end        
            
  end


  private

  def post(url, h)

    r = RestClient.post(url, h.to_json, 
                       headers={content_type: :json, accept: :json})
    JSON.parse r.body, symbolize_names: true

  end

  def respond(intent=nil)

    h = {"version"=>"1.0",
     "session"=>
      {"new"=>true,
       "sessionId"=>"amzn1.echo-api.session.1",
       "application"=>
        {"applicationId"=>""},
       "user"=>
        {"userId"=>""}},
     "context"=>
      {"System"=>
        {"application"=>
          {"applicationId"=>""},
         "user"=>
          {"userId"=>""},
         "device"=>
          {"deviceId"=>"",
           "supportedInterfaces"=>{}},
         "apiEndpoint"=>"https://api.eu.amazonalexa.com",
         "apiAccessToken"=>
          "A"}},
     "request"=> {}
    }
    
    if @userid then
      h['session']['user']['userId'] = @userid
      h['context']['System']['user']['userId'] = @userid     
    end
    
    h['context']['System']['device']['deviceId'] = @deviceid if @deviceid
    
    if @appid then
      h['session']['application']['applicationId'] = @appid
      h['context']['System']['application']['applicationId'] = @appid
    end
    
    
    h['request'] = if intent then
      {
        "type"=>"IntentRequest",
        "requestId"=>"amzn1.echo-api.request.0",
        "timestamp"=>Time.now.utc.iso8601,
        "locale"=>@locale,
        "intent"=>{"name"=>intent, "confirmationStatus"=>"NONE"},
        "dialogState"=>"STARTED"
      }
    else
      {
        "type"=>"LaunchRequest",
        "requestId"=>"amzn1.echo-api.request.a",
        "timestamp"=> Time.now.utc.iso8601,
        "locale"=>@locale,
        "shouldLinkResultBeReturned"=>false
      }      
    end
    
    puts ('before post | h: ' + h.inspect).debug if @debug
    
    r = if block_given? then
    
      puts 'inside block'.info if @debug
      
      symbolize = -> (h) do

        h.inject({}) do |r,x|

          key, val = x    
          r.merge({key.to_sym => val.is_a?(Hash) ? symbolize[val] : val})

        end

      end

      yield(@modelid, symbolize[h]) 
      
    else
      
      post @endpoint, h
      
    end
    
    puts '  degbugger: r: ' + r.inspect if @debug

    speech = r[:response][:outputSpeech]
    speech[:text] || speech[:ssml]

  end

end
