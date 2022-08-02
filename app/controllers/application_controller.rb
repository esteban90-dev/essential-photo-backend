class ApplicationController < ActionController::Base
        include DeviseTokenAuth::Concerns::SetUserByToken

        #disable csrf since we are going to be operating in api mode
        protect_from_forgery with: :null_session
end
