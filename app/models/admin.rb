# frozen_string_literal: true

class Admin < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validate :check_record, on: :create

  def check_record
    if Admin.all.count > 0
      errors.add(:base, message: 'cannot create more than one admin')
    end
  end
end
