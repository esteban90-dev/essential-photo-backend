class Image < ApplicationRecord
  has_one_attached :image
  has_one_attached :thumbnail
  has_many :image_tags
  has_many :tags, through: :image_tags

  validates :image, attached: true, content_type: [:png, :jpg, :jpeg]
end