require 'bigbluebutton_api'
require 'json'

class RoomsController < ApplicationController
  include ApplicationHelper
  include BigBlueButtonHelper
  include LtiHelper
  before_action :set_room, only: [:show, :edit, :update, :destroy, :meeting_join]
  before_action :set_launch_room, only: [:launch]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    respond_to do |format|
      if !@room
        format.html { render :error, status: @error[:status] }
        format.json { render json: {error:  @error[:message]}, status: @error[:status] }
      else
        format.html { render :show }
        format.json { render :show, status: :ok, location: @room }
      end
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: t('default.room.created') }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: t('default.room.updated') }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: t('default.room.destroyed') }
      format.json { head :no_content }
    end
  end

  # GET /rooms/launch?name=&description=&handler=
  # GET /rooms/launch.json?
  def launch
    respond_to do |format|
      if @room.save
        format.html { redirect_to @room }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /rooms/:id/meeting/join
  # GET /rooms/:id/meeting/join.json
  def meeting_join
    bbb ||= BigBlueButton::BigBlueButtonApi.new(bigbluebutton_endpoint, bigbluebutton_secret, "0.8", true)
    if !bbb
      @error = { :key => t('error.bigbluebutton.invalidrequest.key'), :message => t('error.bigbluebutton.invalidrequest.message'), :suggestion => t('error.bigbluebutton.invalidrequest.suggestion'), :status => :internal_server_error }
    end

    options = {
      :moderatorPW => @room.moderator,
      :attendeePW => @room.viewer,
      :welcome => @room.welcome,
      :record => @room.recording,
      :logoutURL => 'javascript:window.close();',
    }
    bbb.create_meeting(@room.name, @room.handler, options)

    role_token = is_moderator || @room.all_moderators ? options[:moderatorPW] : options[:viewerPW]
    join_meeting_url = bbb.join_meeting_url(@room.handler, username(is_moderator? ? t('default.bigbluebutton.moderator') : t('default.bigbluebutton.viewer')), role_token)

    if @error
      respond_to do |format|
        format.html { render :error, status: @error[:status] }
        format.json { render json: {error:  @error[:message]}, status: @error[:status] }
      end
    else
      redirect_to join_meeting_url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @error = nil
      begin
        @room = Room.find(params[:id])
        unless cookies[@room.handler]
          @error = { :key => t('error.room.forbiden.key'), :message => t('error.room.forbiden.message'), :suggestion => t('error.room.forbiden.suggestion'), :status => :forbidden }
          @room = nil
          return
        end
        @handler_params = JSON.parse(cookies[@room[:handler]])
      rescue ActiveRecord::RecordNotFound => e
        @error = { :key => t('error.room.notfound.key'), :message => t('error.room.notfound.message'), :suggestion => t('error.room.notfound.suggestion'), :status => :not_found }
        @room = nil
      end
    end

    def set_launch_room
      @error = nil
      unless cookies[params[:handler]]
        @error = { :key => t('error.room.forbiden.key'), :message => t('error.room.forbiden.message'), :suggestion => t('error.room.forbiden.suggestion'), :status => :forbidden }
        @room = nil
        return
      end
      @handler_params = JSON.parse(cookies[params[:handler]])
      @room = Room.find_by(handler: params[:handler]) || Room.new(launch_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:name, :description, :welcome, :moderator, :viewer, :recording, :wait_moderator, :all_moderators)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def launch_params
      moderator_token = role_token
      params.permit(:handler).merge(
        {
          name: @handler_params["resource_link_title"],
          description: @handler_params["resource_link_description"],
          welcome: "",
          moderator: moderator_token,
          viewer: role_token(moderator_token),
          recording: false,
          wait_moderator: false,
          all_moderators: false
        }
      )
    end

    def role_token(base = nil)
      token = random_password(8)
      while token == base do
        token = random_password(8)
      end
      token
    end
end
