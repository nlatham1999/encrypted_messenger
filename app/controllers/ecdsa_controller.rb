class EcdsaController < ApplicationController
    def keys

        group = ECDSA::Group::Secp256k1
        private_key = 1 + SecureRandom.random_number(group.order - 1)
        puts 'private key: %#x' % private_key

        public_key = group.generator.multiply_by_scalar(private_key)
        puts 'public key: '
        puts '  x: %#x' % public_key.x
        puts '  y: %#x' % public_key.y

        @keys = { "private_key" => private_key, "public_key" => {"x" => public_key.x, "y" => public_key.y} }
    end
end