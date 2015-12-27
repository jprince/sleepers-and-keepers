class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :deep_snake_case_params!

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |user|
      user.permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
  end

  def deep_snake_case_params!(val = params)
    case val
    when Array
      val.map { |v| deep_snake_case_params!(v) }
    when Hash
      val.keys.each do |k, v = val[k]|
        val.delete k
        val[k.underscore] = deep_snake_case_params!(v)
      end

      val
    else
      val
    end
  end
end
