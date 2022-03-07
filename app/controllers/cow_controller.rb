# app/controllers/cow_controller.rb
class CowController < ApplicationController
    def say
      @message = Cow.new.say(params[:message])
    end
end