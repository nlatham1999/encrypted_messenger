module Errors
    class NoUser < Errors::StandardError
        def initialize
            super(
            title: "User not found",
            status: 404,
            detail: "user not added for this address please generate or add new user",
            source: { pointer: "/recieve" }
            )
        end
    end
end