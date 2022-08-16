class Image < ApplicationRecord
  has_one_attached :image
  has_one_attached :thumbnail

  validates :image, attached: true, content_type: [:png, :jpg, :jpeg]
end