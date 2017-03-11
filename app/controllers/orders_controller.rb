class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  include AASM

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  def approve
    @order = Order.find(params[:id])
    if (@order.may_approve? && (current_user.approver_role? || current_user.superadmin_role?))
      respond_to do |format|
        @order.approve
        if @order.save
          format.html { redirect_to rails_admin.show_path(model_name: 'Order', id: @order.id), :flash => { :success => "Order was successfully approved." } }
        end
      end
    else
      redirect_to rails_admin.show_path(model_name: 'Order', id: @order.id), :flash => { :warning => "Unable to approve order." }
    end
  end

  def reject
    @order = Order.find(params[:id])
    if (@order.may_reject? && (current_user.approver_role? || current_user.superadmin_role?))
      respond_to do |format|
        @order.reject
        if @order.save
          format.html { redirect_to rails_admin.show_path(model_name: 'Order', id: @order.id), :flash => { danger: 'Order was successfully rejected.'} }
        end
      end
    else
      redirect_to rails_admin.show_path(model_name: 'Order', id: @order.id), :flash => { :warning => "Unable to reject order." }
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @order.user_id = current_user.id

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:name, :description, :price, :quantity, :supplier, :link, :part_number)
    end
end
