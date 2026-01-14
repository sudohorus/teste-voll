module Api
    module V1
        class AuthenticationController < ApplicationController
            def login
                @user = User.find_by_email(params[:email])

                if @user&.authenticate(params[:password])
                    token = jwt_encode(user_id: @user.id)
                    render json: { token: token }, status: :ok
                else
                    render json: { error: "unauthorized" }, status: :unauthorized 
                end
            end

            private
            
            def jwt_encode(payload, exp = 24.hours.from_now)
                payload[:exp] = exp.to_i
                JWT.encode(payload, Rails.application.secret_key_base)
            end

            def jwt_decode(token)
                decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
                HashWithIndifferentAccess.new(decoded)
            end
        end
    end
end
