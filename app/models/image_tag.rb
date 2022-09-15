class ImageTag < ApplicationRecord
  belongs_to :tag
  belongs_to :image

  after_destroy :destroy_associated_tag_if_orphan

  def destroy_associated_tag_if_orphan
    # if associated tag doesn't have any other ImageTag records, destroy it too
    # to prevent orphaned records
    if self.tag && self.tag.image_tags.none?
      self.tag.destroy
    end
  end
end