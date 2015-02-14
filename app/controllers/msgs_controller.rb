class MsgsController < ApplicationController
  def new
    session[:my_msgs] ||= []
    # housekeeping - delete old files in a background thread
    background = Thread.new do
      destroyed = Msg.where('created_at < :before', before: Time.now-30.days).destroy_all.map {|x| x.id.to_s}
      session[:my_msgs] -= destroyed
      logger.info "Deleted old files: #{destroyed}"
    end
    @msg = Msg.new
  end

  def create
    @msg = Msg.new file: params[:file], name: params[:file].original_filename
    logger.debug @msg.errors.full_messages
    if @msg.save
      session[:my_msgs] << @msg.id.to_s
      respond_to do |format|
        format.json { render json: {msgs_path: msg_path(@msg)} }
        #format.js { render :js => "window.location = '#{msgs_path @msg}'" }
      end
    else
      respond_to do |format|
        format.json { render json: @msg.errors.full_messages.uniq , status: :unprocessable_entity }
      end
    end
  end

  def show
    if session[:my_msgs] && session[:my_msgs].include?(params[:id])
      @msg = Msg.find(params[:id])
    else
      logger.debug "404!"
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def view_attachment
    @attachment = Msg.find(params[:id]).attachments[params[:attachment_id].to_i]
    content_type = case @attachment.filename
    when /sql$/i, /txt$/i
      'text/plain'
    when /html$/i, /htm$/i
      'text/html'
    else
      'application/octet-stream'
    end
    render body: @attachment.data.read, content_type: content_type
  end

end
