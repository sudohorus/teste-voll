class MessagesChannel < ApplicationCable::Channel
    def subscribed
        stream_from "messages_#{params[:user_id]}"
    end

    def unsubscribed
        stop_all_streams
    end
end