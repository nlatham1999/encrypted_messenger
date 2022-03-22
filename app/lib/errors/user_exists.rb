module Errors
    class UserExists < Errors::StandardError
        def initialize
            super(
            title: "username already exists",
            status: 406,
            detail: "please use another username, this one already exists",
            source: { pointer: "/generate" }
            )
        end
    end
end