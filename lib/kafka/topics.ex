defmodule Kafka.Topics do
  #Authentication
  def authentication_sign_up do
    "sign_up"
  end
  def answer_authentication_sign_in do
    "sign_in"
  end
  def authentication_token_create do
    "token_create"
  end
  #Email
  def confirm_email do
    "confirm_email"
  end

  def forget_password do
    "forget_password"
  end
  def answer_email do
    "answer_email"
  end
  def change_password_activated do
    "change_password_activated"
  end
  #Facebook

  def sign_up_facebook do
    "sign_up_facebook"
  end

  def sign_in_facebook do
    "sign_in_facebook"
  end

  def fetch_userid_facebook do
    "fetch_userid_faceboo"
  end

  def answer_facebook do
    "facebook_answer"
  end

  def facebook_id_answer do
    "facebook_id_answer"
  end
  # Instagram
  def sign_up_instagram do
    "sign_up_instagram"
  end

  def sign_in_instagram do
    "sign_in_instagram"
  end

  def fetch_userid_instagram do
    "fetch_userid_instagram"
  end

  def answer_instagram do
    "instagram_answer"
  end

  def instagram_id_answer do
    "instagram_id_answer"
  end
  #Notification
  def save_device_token do
    "save_device_token"
  end
  #Photo
  def photo_api do
    "userpicPhotoApiFetch"
  end
  def answer_photo_api do
    "userpicPhotoApiFetchAnswer"
  end
end
