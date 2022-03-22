include Errors

# adds the username for the public key
# if a username already exists for that public key then it will be overriden
class GenerateController < ApplicationController

    MONGODB_CONN_URL = ENV['MONGODB_URL']

    def user
        # verification
        begin
            params.require(:username)
            # params.require(:min)

            # get parameters
            username = params[:username]

            curve = OpenSSL::PKey::EC.new('secp256k1')

            curve.generate_key

            private_key = Base58.int_to_base58(Integer(curve.private_key.to_s()))

            h =  curve.public_key.to_bn().to_s(16)

            hash = Digest::SHA2.new(256).hexdigest h
            hash_58 =  Base58.int_to_base58(hash.to_i(16))
            
            # connect to mongo
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # connect to collection
            db = client.database
            collection = db[:users]
            
            records = collection.find(:username => username).first

            raise Errors::UserExists unless records == nil || records.count() == 0

            # insert data
            doc = {
                "address": hash_58,
                "username": username
            }
            result = collection.insert_one(doc)
            status_message = "added new record at " + result.inserted_id

            @message = { "private_key" => private_key, "address" => hash_58, "status_message" => status_message }

            return
                
        rescue Errors::UserExists
            e = Errors::UserExists.new
        rescue => exception
            e = Errors::Internal.new
        end

        render json: ErrorSerializer.new(e), status: e.status
    end
end