module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json

      def show
        respond_with User.find(params[:id])
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user.to_json, status: 201, location: [:api, user]
        else
          render json: { errors: user.errors }.to_json, status: 422
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
