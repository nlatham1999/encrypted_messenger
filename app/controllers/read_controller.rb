include Errors

class ReadController < ApplicationController
    
    MONGODB_CONN_URL = ENV['MONGODB_URL']
    
    def messages
        begin
            # verification
            params.require(:username)
            params.require(:pass_phrase)

            # get the parameters
            username = params[:username]
            pass_phrase_and_salt = params[:pass_phrase]

            # split up salt and passphrase
            raise Errors::Passphrase unless pass_phrase_and_salt.length >= 16

            pass_phrase = pass_phrase_and_salt[0..-9]
            salt = pass_phrase_and_salt[-8..-1]

            message_type = ""
            if params[:message_type].present?
                message_type = params[:message_type]
            end
            
            # connect to mongo
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # connect to collection
            db = client.database
            collection = db[:messages]

            if message_type == ""
                records = collection.find(:username => username)
            else
                records = collection.find({:username => username, :message_type => message_type})
            end

            m = []
            records.each do |rec|
                message_found = rec[:message]

                decoded = Base64.decode64 message_found.encode('ascii-8bit')

                decryptor = OpenSSL::Cipher.new 'aes-256-cbc'
                decryptor.decrypt
                decryptor.pkcs5_keyivgen pass_phrase, salt

                plain = decryptor.update decoded
                plain << decryptor.final
                m.append(plain)
            end

            @message = {"status" => 200, "messages": m}
            return
        rescue Errors::Passphrase
            e = Errors::Passphrase.new
        rescue => exception
            e = Errors::Internal.new
        end
        render json: ErrorSerializer.new(e), status: e.status
    end
end