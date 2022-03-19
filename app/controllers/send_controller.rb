include Errors

class SendController < ApplicationController

    MONGODB_CONN_URL = "mongodb+srv://Admin:100Admin!@cluster0.ovcjj.mongodb.net/Cluster0?retryWrites=true&w=majority"

    def message
        # verification
        params.require(:message)
        # params.require(:writer)
        params.require(:private_key)
        params.require(:public_key_x)
        params.require(:public_key_y)
        params.require(:pass_phrase)
        params.require(:salt)
        # params.require(:min)

        # get parameters
        message = params[:message]
        private_key = Integer(params[:private_key])
        public_key_x = Integer(params[:public_key_x])
        public_key_y = Integer(params[:public_key_y])
        pass_phrase = params[:pass_phrase]
        salt = String(params[:salt])

        # authentifcation
        group = ECDSA::Group::Secp256k1
        public_key = group.generator.multiply_by_scalar(Integer(private_key))
        
        begin 
            raise Errors::Unauthorized unless public_key.x == public_key_x and public_key.y == public_key_y
        rescue Errors::Unauthorized
            e = Errors::Unauthorized.new
            render json: ErrorSerializer.new(e), status: e.status
        end

        # encrypt using PKCS5
        encryptor = OpenSSL::Cipher.new 'aes-256-cbc'
        encryptor.encrypt
        encryptor.pkcs5_keyivgen pass_phrase, salt

        encrypted = encryptor.update message
        encrypted << encryptor.final

        # encode the message into utf-8 so we can store it
        encoded = Base64.encode64(encrypted).encode('utf-8')

        puts encoded

        # connect to mongo
        Mongo::Logger.logger.level = ::Logger::FATAL 
        client = Mongo::Client.new(MONGODB_CONN_URL)

        # connect to collection
        db = client.database
        collection = db[:messages]

        # insert data
        doc = {"message": encoded }
        result = collection.insert_one(doc)

        # set status message
        @message = "Record inserted - id: #{result.inserted_id}"

    end
end