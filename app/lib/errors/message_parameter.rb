# error for when the message provided is empty

module Errors
    class MessageParameter < Errors::StandardError
        def initialize
            super(
            title: "parameter error",
            status: 400,
            detail: "message cannot be an empty string",
            source: { pointer: "/" }
            )
        end
    end
end