# error for when the passphrase provided is less than the required amount

module Errors
    class Passphrase < Errors::StandardError
        def initialize
            super(
            title: "passphrase error",
            status: 400,
            detail: "passphrase must be at least 16 characters",
            source: { pointer: "/" }
            )
        end
    end
end