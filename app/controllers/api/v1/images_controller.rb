class Api::V1::ImagesController < ApplicationController
  require "image_processing/mini_magick"

  def create
    # build new image
    @image = Image.new
    @image.fullsized_image.attach(params[:image])

    # create thumbnail too
    thumbnail = ImageProcessing::MiniMagick
      .source(params[:image].tempfile.path)
      .resize_to_limit(400, 400)
      .call

    filename = params[:image].original_filename
    thumbnail_filename = filename.insert(filename.index('.'), '_thumb')
    @image.thumbnail_image.attach(io: thumbnail, filename: thumbnail_filename)
    
    if @image.save
      render json: {
        id: @image.id,
        fullsized_image_url: url_for(@image.fullsized_image),
        thumbnail_image_url: url_for(@image.thumbnail_image),
        created_at: @image.created_at,
        updated_at: @image.updated_at,
      }, status: :created
    end
  end

end