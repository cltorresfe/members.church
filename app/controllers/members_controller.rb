class MembersController < ApplicationController
  before_action :set_member, only: [:edit, :update, :destroy]
  before_action :load_ministries, only: [:new, :edit]
  skip_before_filter :authenticate_user!, only: :index

  # GET /members
  # GET /members.json
  def index
    if params[:name].present?
      @members = Member.search(params[:name])
      if(@members.present? && @members.size == 1)
        redirect_to edit_member_path(@members.first)
      else
        @members = @members.paginate(page: params[:page], per_page: 18)
        respond_to do |format|
          format.html # index.html.erb
        end
      end
    else
      @members = Member.paginate(page: params[:page], per_page: 18)
    end
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        WelcomeMember.notify(@member).deliver_later!
        flash[:notice] = 'Member was successfully created.'
        format.html { redirect_to action: :index}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        flash[:notice] = 'Member was successfully updated.'
        format.html { redirect_to action: :index}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:name, :adress, :email, :phone, :status_id, :church_id, charge_ids:[])
    end

    def load_ministries
      @ministries = Ministry.all
    end

end
