class Api::V1::ImagesController < ApplicationController
  require "image_processing/mini_magick"

  before_action :authenticate_api_v1_admin!, except: :index

  def index
    # only return public images
    @images = Image.where(is_public: true)
    formatted_images = @images.map{ |image| formatted_image(image) }
    render json: formatted_images, status: :ok
  end

  def create
    # build new image object
    @image = Image.new

    # by default, make image publicly available
    @image.is_public = true

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
      render json: formatted_image(@image), status: :created
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @image = Image.find(params[:id])
    @image.title = params[:title]
    @image.description = params[:description]
    @image.is_public = params[:is_public]

    # for each tag from request, if the tag exists then associate
    # with the image, otherwise create a new tag
    params[:tags].split(", ").each do |tag_name|
      tag = Tag.find_by(name: tag_name)
      if tag
        @image.tags << tag
      else
        @image.tags.create(name: tag_name)
      end
    end

    if @image.save
      render json: formatted_image(@image), status: :ok
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def formatted_image(image)
    return {
      id: image.id,
      title: image.title,
      description: image.description,
      tags: image.tags,
      image_url: url_for(image.image),
      thumbnail_url: url_for(image.thumbnail),
      created_at: image.created_at,
      updated_at: image.updated_at,
    }
  end
end