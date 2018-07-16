require 'bigbluebutton_api'
require 'oauth2'
require 'json'
require 'rest-client'

class RoomsController < ApplicationController
  include ApplicationHelper
  include BigBlueButtonHelper
  include LtiHelper
  #skip_before_action :authenticate_user!, only: %i[:launch], :raise => false
  before_action :authenticate_user!, :raise => false, only: %i[launch]
  before_action :set_launch_room, only: %i[launch]
  before_action :set_room, only: %i[show edit update destroy meeting_join meeting_end meeting_close]
  before_action :check_for_cancel, :only => [:create, :update]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> show"
    logger.info params
    respond_to do |format|
      if @room
        format.html { render :show }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :error, status: @error[:status] }
        format.json { render json: {error:  @error[:message]}, status: @error[:status] }
      end
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit; end

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
        format.json { render json: @error, status: :unprocessable_entity }
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
        format.json { render json: @error, status: :unprocessable_entity }
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

  # GET /launch?name=&description=&handler=
  # GET /launch.json?
  def launch
    logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> launch"
    logger.info params
    respond_to do |format|
      if @room
        format.html { render :show }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :error }
        format.json { render json: @error, status: :unprocessable_entity }
      end
    end
  end

  # GET /rooms/:id/meeting/join
  # GET /rooms/:id/meeting/join.json
  def meeting_join
    redirect_to join_meeting_url
  end

  # GET /rooms/:id/meeting/end
  # GET /rooms/:id/meeting/end.json
  def meeting_end
  end

  # GET /rooms/:id/meeting/close
  def meeting_close
    respond_to do |format|
      format.html { render :autoclose }
    end
  end

  private

    def authenticate_user!
      logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> authenticate_user!"
      logger.info params
      # Assume user authenticated if session[:uid] is set
      return if session[:uid]
      if params['action'] == 'launch'
        cookies[:launch_params] = { :value => params.except(:app, :controller, :action).to_json, :expires => 30.minutes.from_now }
        redirect_to "#{omniauth_path(:doorkeeper)}"
        return
      end
      redirect_to errors_path(401)
    end

    def join_meeting_url
      return unless @room && @launch_params
      bbb ||= BigBlueButton::BigBlueButtonApi.new(bigbluebutton_endpoint, bigbluebutton_secret, "0.8", true)
      unless bbb
        @error = { key: t('error.bigbluebutton.invalidrequest.code'), message:  t('error.bigbluebutton.invalidrequest.message'), suggestion: t('error.bigbluebutton.invalidrequest.suggestion'), :status => :internal_server_error }
        return
      end
      bbb.create_meeting(@room.name, @room.handler, {
        :moderatorPW => @room.moderator,
        :attendeePW => @room.viewer,
        :welcome => @room.welcome,
        :record => @room.recording,
        :logoutURL => autoclose_url,
      })
      role_token = (moderator? || @room.all_moderators) ? @room.moderator : @room.viewer
      role_identifier = moderator? ? t('default.bigbluebutton.moderator') : t('default.bigbluebutton.viewer')
      bbb.join_meeting_url(@room.handler, username(@launch_params, role_identifier), role_token)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_room
      logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> set_room"
      @launch_params = nil
      @room = nil
      @error = nil
      begin
        @room = Room.find(params[:id])
        unless cookies[@room.handler] || session['admin']
          @room = nil
          @error = { key: t('error.room.forbiden.code'), message:  t('error.room.forbiden.message'), suggestion: t('error.room.forbiden.suggestion'), :status => :forbidden }
          return
        end
        @launch_params = JSON.parse(cookies[@room.handler])
      rescue ActiveRecord::RecordNotFound => e
        @error = { key: t('error.room.notfound.code'), message:  t('error.room.notfound.message'), suggestion: t('error.room.notfound.suggestion'), :status => :not_found }
      end
    end

    def set_launch_room
      logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> set_launch_room"
      logger.info params
      @launch_params = nil
      @room = nil
      @error = nil
      session['admin'] = false
      #####################################################
      url = "#{lti_tool_provider_api_v1_sso_url}/launches/#{params['token']}"
      client_id = ENV['OMNIAUTH_DOORKEEPER_KEY']
      client_secret = ENV['OMNIAUTH_DOORKEEPER_SECRET']
      oauth2_url = "#{lti_tool_provider_url}/oauth/token"
      response = RestClient.post(oauth2_url, {grant_type: 'client_credentials', client_id: client_id, client_secret: client_secret})
      json_response = JSON.parse(response)
      token = json_response["access_token"]
      sso = JSON.parse(RestClient.get(url, {'Authorization' => "Bearer #{token}"}))
      logger.info sso
      #####################################################
      unless sso["valid"]
        @error = { key: t('error.room.forbiden.code'), message:  t('error.room.forbiden.message'), suggestion: t('error.room.forbiden.suggestion'), :status => :forbidden }
        return
      end
      @launch_params = sso["message"]
      @room = Room.find_by(handler: params[:handler]) || Room.create!(new_room_params(@launch_params['resource_link_title'], @launch_params['resource_link_description']))
      logger.info @room
      cookies[params[:handler]] = { :value => @launch_params.to_json, :expires => 30.minutes.from_now }
      session['admin'] = admin?
    end

    def room_params
      params.require(:room).permit(:name, :description, :welcome, :moderator, :viewer, :recording, :wait_moderator, :all_moderators)
    end

    def new_room_params(name, description)
      moderator_token = role_token
      params.permit(:handler).merge({
        name: name,
        description: description,
        welcome: '',
        moderator: moderator_token,
        viewer: role_token(moderator_token),
        recording: false,
        wait_moderator: false,
        all_moderators: false
      })
    end

    def role_token(base = nil)
      token = random_password(8)
      while token == base
        token = random_password(8)
      end
      token
    end

    def check_for_cancel
      if params[:cancel]
        redirect_to @room
      end
    end

    def lti_tool_provider_url
      "#{ENV['OMNIAUTH_DOORKEEPER_SITE']}#{ENV['OMNIAUTH_DOORKEEPER_ROOT'] ? '/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] : ''}"
    end

    def lti_tool_provider_api_v1_sso_url
      "#{lti_tool_provider_url}/api/v1/sso"
    end

end
