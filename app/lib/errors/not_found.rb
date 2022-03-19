module Errors
    class NotFound < Errors::StandardError
        def initialize
            super(
            title: "Record not Found",
            status: 404,
            detail: "We could not find the record you were looking for.",
            source: { pointer: "/recieve" }
            )
        end
    end
end