module Errors
    class NoUser < Errors::StandardError
        def initialize
            super(
            title: "User not found",
            status: 404,
            detail: "user not added for this address please generate a new user and keypair or add new user with the keypair you have",
            source: { pointer: "/recieve" }
            )
        end
    end
end