class Api::V1::ImagesController < ApplicationController
  def create
    @image = Image.new(image_params)
    
    if @image.save
      render json: {
        id: @image.id,
        filename: @image.image.filename,
        url: url_for(@image.image),
        created_at: @image.created_at,
        updated_at: @image.updated_at,
      }, status: :created
    end
  end

  private

  def image_params
    params.require(:image).permit(:image)
  end
end