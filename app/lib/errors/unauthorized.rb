module Errors
    class Unauthorized < Errors::StandardError
      def initialize
        super(
          title: "Unauthorized",
          status: 401,
          detail: "unauthorized access",
          source: { pointer: "/send" }
        )
      end
    end
end