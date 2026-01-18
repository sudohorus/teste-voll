module Api
    module V1
        class MessagesController < ApplicationController
            before_action :authorize_request

            def create
                message = @current_user.sent_messages.build(message_params)

                if message.save
                    ActionCable.server.broadcast(
                        "messages_#{message.sender_id}",
                        message.as_json
                    )
                    ActionCable.server.broadcast(
                        "messages_#{message.receiver_id}",
                        message.as_json
                    )

                    render json: message, status: :created
                else
                    render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
                end
            end

            def index
                messages = Message.where("sender_id = ? OR receiver_id = ?", @current_user.id, @current_user.id).order(created_at: :desc)
                render json: messages, status: :ok
            end

            def show
                other_user_id = params[:id]
                page = (params[:page] || 1).to_i
                per_page = (params[:per_page] || 20).to_i
                offset = (page - 1) * per_page

                messages = Message.where(
                    "(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                    @current_user.id, other_user_id,
                    other_user_id, @current_user.id
                ).order(created_at: :desc)
                 .limit(per_page)
                 .offset(offset)
                
                render json: messages.reverse, status: :ok
            end

            private

            def message_params
                params.require(:message).permit(:receiver_id, :content)
            end

            def authorize_request
                header = request.headers['Authorization']
                token = header.split(' ').last if header

                begin
                    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
                    @current_user = User.find(decoded['user_id'])
                rescue
                    render json: { error: 'Unauthorized' }, status: :unauthorized
                end
            end
        end
    end
end
