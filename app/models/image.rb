class Image < ApplicationRecord
  has_one_attached :fullsized_image
  has_one_attached :thumbnail_image
end