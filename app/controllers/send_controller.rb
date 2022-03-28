include Errors

class SendController < ApplicationController

    MONGODB_CONN_URL = ENV['MONGODB_URL']

    def message
        # verification
        begin
            params.require(:private_key)
            params.require(:address)
            params.require(:pass_phrase)
            params.require(:message)
            # params.require(:min)

            # get parameters
            message = params[:message]
            private_key = params[:private_key]
            address = params[:address]
            pass_phrase_and_salt = params[:pass_phrase]

            message_type = ""
            if params[:message_type].present?
                message_type = params[:message_type]
            end

            # make sure message is not empty
            raise Errors::MessageParameter unless message != ""

            # split up salt and passphrase
            raise Errors::Passphrase unless pass_phrase_and_salt.length >= 16
            
            pass_phrase = pass_phrase_and_salt[0..-9]
            salt = pass_phrase_and_salt[-8..-1]

            # authentication
            authentication(private_key, address)

            # encrypt using PKCS5
            encryptor = OpenSSL::Cipher.new 'aes-256-cbc'
            encryptor.encrypt
            encryptor.pkcs5_keyivgen pass_phrase, salt

            encrypted = encryptor.update message
            encrypted << encryptor.final

            # encode the message into utf-8 so we can store it
            encoded = Base64.encode64(encrypted).encode('utf-8')

            # connect to mongo
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # connect to collection
            db = client.database
            collection = db[:messages]

            # check to make sure the username is there
            user_collection = db[:users]
            user_record = user_collection.find(:address => address).first
            raise Errors::NoUser unless user_record != nil and user_record[:username] != nil

            username = user_record[:username]

            # insert data
            doc = {
                "dateCreated": DateTime.now,
                "message": encoded, 
                "address": address ,
                "message_type": message_type,
                "username": username
            }
            result = collection.insert_one(doc)

            # set status message
            @message = { "status" => 200, "id" => result.inserted_id[:_id].to_s}
            return
                
        # error handling
        rescue Errors::MessageParameter
            e = Errors::MessageParameter.new
        rescue Errors::Unauthorized
            e = Errors::Unauthorized.new
        rescue Errors::Passphrase
            e = Errors::Passphrase.new
        rescue Errors::NoUser
            e = Errors::NoUser.new
        rescue => exception
            e = Errors::Internal.new
        end
        render json: ErrorSerializer.new(e), status: e.status
    end

    def authentication(private_key, address)

        # generate the public key
        private_key_int = Base58.base58_to_int(private_key)
        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        public_key = group.generator.mul(private_key_int)

        # hash the public key and compare
        h =  public_key.to_bn().to_s(16)
        hash = Digest::SHA2.new(256).hexdigest h
        hash_58 =  Base58.int_to_base58(hash.to_i(16))

        raise Errors::Unauthorized unless hash_58 == address
    end
end