class Api::V1::ImagesController < ApplicationController
  require "image_processing/mini_magick"

  before_action :authenticate_api_v1_admin!

  def create
    # build new image object
    @image = Image.new

    if params[:image]
      # attach the image to the image object
      @image.image.attach(params[:image])

      # create and attach a thumbnail too
      thumbnail = ImageProcessing::MiniMagick
        .source(params[:image].tempfile.path)
        .resize_to_limit(400, 400)
        .call

      filename = params[:image].original_filename
      thumbnail_filename = filename.insert(filename.index('.'), '_thumb')
      @image.thumbnail.attach(io: thumbnail, filename: thumbnail_filename)
    end
    
    if @image.save
      render json: {
        id: @image.id,
        image_url: url_for(@image.image),
        thumbnai_url: url_for(@image.thumbnail),
        created_at: @image.created_at,
        updated_at: @image.updated_at,
      }, status: :created
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

end