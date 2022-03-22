include Errors

# adds the username for the public key
# if a username already exists for that public key then it will be overriden
class AddController < ApplicationController

    MONGODB_CONN_URL = ENV['MONGODB_URL']

    def user
        # verification
        begin
            params.require(:private_key)
            params.require(:address)
            params.require(:username)
            # params.require(:min)

            # get parameters
            private_key = params[:private_key]
            address = params[:address]
            username = params[:username]

            # authentication
            authentication(private_key, address)

            # connect to mongo
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # connect to collection
            db = client.database
            collection = db[:users]

            # insert data
            doc = {
                "address": address,
                "username": username
            }
            
            records = collection.find(:address => address).first

            status_message = ""
            if records != nil and records.count() != 0
                collection.update_one({"address": address},{'$set' => {"username": username}})
                puts records
                status_message = "updated found record at " + records[:_id]
            else
                result = collection.insert_one(doc)
                status_message = "added new record at " + result.inserted_id
            end


            # set status message
            @message = { "status" => 200, "status_message" => status_message}
            return
                
        # error handling
        rescue Errors::MessageParameter
            e = Errors::MessageParameter.new
        rescue Errors::Unauthorized
            e = Errors::Unauthorized.new
        rescue Errors::Passphrase
            e = Errors::Passphrase.new
        # rescue => exception
        #     e = Errors::Internal.new
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