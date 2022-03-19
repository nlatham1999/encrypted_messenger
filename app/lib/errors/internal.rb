module Errors
    class Internal < Errors::StandardError
        def initialize
            super(
            title: "Internal Error",
            status: 500,
            detail: "Internal Error",
            source: { pointer: "/recieve" }
            )
        end
    end
end