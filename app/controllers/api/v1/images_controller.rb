class Api::V1::ImagesController < ApplicationController
  require "image_processing/mini_magick"

  before_action :authenticate_api_v1_admin!, except: :index

  def index
    # if the admin is signed in and supplies the 'include_private=true' query 
    # parameter, return all images, otherwise only return public images

    if params[:include_private]
      if api_v1_admin_signed_in? && params[:include_private] == 'true'
        @images = Image.all
      end
    else 
      @images = Image.where(is_public: true)
    end

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

    # expect tags to be separated by comma,
    # and strip leading/trailing whitespace
    new_tag_names = params[:tags].split(",").map{|tag| tag.strip}
    
    # delete any tags associated with the image that
    # don't appear in params
    tag_ids = @image.tags.where.not(name: new_tag_names).map{|tag| tag.id}
    tag_ids.each do |tag_id|
      ImageTag.where(image_id: @image.id, tag_id: tag_id).each{|image_tag| image_tag.destroy}
    end

    # attach new tags to image
    new_tag_names.each do |new_tag_name|
      existing_tag = Tag.find_by_name(new_tag_name)

      # if there is already an existing tag that matches the new tag name
      # and the image doesn't already have that tag, attach it to the image
      # otherwise, create a new tag
      if existing_tag 
        if !@image.tags.include?(existing_tag)
          @image.tags << existing_tag
        end
      else 
        @image.tags.create(name: new_tag_name)
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
      is_public: image.is_public,
      image_url: url_for(image.image),
      thumbnail_url: url_for(image.thumbnail),
      created_at: image.created_at,
      updated_at: image.updated_at,
    }
  end
end