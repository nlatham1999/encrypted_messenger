# app/controllers/cow_controller.rb
class CowController < ApplicationController
    def say
      @message = 'hello world'
    end
end