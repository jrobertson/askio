# Introducing the AskIO gem

## Usage

    require 'askio'
    require 'alexa_modelbuilder'

    file = '/home/james/leo.txt'
    userid = 'amzn1.ask.account.AG5AXXXXX'

    amb = AlexaModelBuilder.new(File.read file)
    aio = AskIO.new(amb.to_manifest, amb.to_model,userid: userid)
    aio.ask 'what is my user id'


file: leo.txt

<pre>
name: leo
invocation: leo

Inspect
  What is my user id
  to find out my user id
ModelUpdate
  Update the model
  to update the model
  update model
  to update model
MyWeeklySchedule
  What am I doing this week
  about this week
  what am I doing week
  what is happening on week
  what is happening this week
  what's happening on week
  what's happening this week

endpoint: https://mywebserver.com/do/leo/ask
</pre>

## Resources

* askio https://rubygems.org/gems/askio

botbase module alexa skill gem model chat askio
