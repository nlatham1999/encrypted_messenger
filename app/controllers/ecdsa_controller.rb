class EcdsaController < ApplicationController
    def keys
        curve = OpenSSL::PKey::EC.new('secp256k1')
        curve.generate_key

        private_key = Base58.int_to_base58(Integer(curve.private_key.to_s()))

        h =  curve.public_key.to_bn().to_s(16)

        hash = Digest::SHA2.new(256).hexdigest h
        hash_58 =  Base58.int_to_base58(hash.to_i(16))

        @message = { "private_key" => private_key, "address" => hash_58 }
    end
end