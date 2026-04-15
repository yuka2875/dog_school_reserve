class ReservationsController < ApplicationController
  def customer_info
    @reservation = Reservation.new
  end

  def customers
    if params[:search].present?
      @customers = Customer.where(
        "owner_name LIKE :q OR phone_number LIKE :q OR dog_name LIKE :q",
        q: "%#{params[:search]}%"
        ).order(created_at: :desc)
    else
      @customers = Customer.order(created_at: :desc)
    end
  end

  def destroy_customer
    customer = Customer.find(params[:id])

    if customer.destroy
      redirect_to "/admin/customers"
    else
      redirect_to "/admin/customers", alert: "予約があるため削除できません"
    end
  end

  def edit_customer
    @customer = Customer.find(params[:id])
  end

  def update_customer
    @customer = Customer.find(params[:id])

    if @customer.update(customer_params)
      redirect_to "/admin/customers"
    else
      render :edit_customer
    end
  end

  def new_customer
    @customer = Customer.new
  end

  def create_customer
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to "/admin/customers"
    else
      render :new_customer
    end
  end

  def admin
    @reservations = Reservation.order(created_at: :desc)

    today_pickups = Reservation.where(
      reserved_date: Date.today
    ).where(pickup_required: [ true, "true" ])

    @pickup_addresses = today_pickups.pluck(:address).compact.sort

    @stats = {
      total_customers: 248,
      monthly_bookings: 87,
      completed_bookings: 156,
      monthly_sales: "¥892,000"
    }
    today = Date.today

    slot_times = [ "09:00", "12:00", "15:00", "18:00" ]

    @time_slots = slot_times.map do |time|
      booked_count = Reservation.where(
        reserved_date: @selected_date,
        reserved_time: time
      ).count

      {
        time: "#{time} - #{(Time.parse(time) + 1.hour).strftime('%H:%M')}",
        value: time,
        available: 10 - booked_count,
        total: 10
      }
    end
  end
  def index
    @reservation = Reservation.new(reservation_params)
    @reservation_data = reservation_params.to_h
    year = params[:year]&.to_i || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    day = params[:day]&.to_i || Date.today.day

    @selected_date = Date.new(year, month, day)
    @reservation = Reservation.new

    first_day = Date.new(year, month, 1)
    @start_wday = first_day.wday

    @days = (1..Date.new(year, month, -1).day).to_a

    @prev_month = @selected_date.prev_month
    @next_month = @selected_date.next_month

    @selected_time = params[:time]

    slot_times = [ "09:00", "12:00", "15:00", "18:00" ]

    @time_slots = slot_times.map do |time|
      booked_count = Reservation.where(
        reserved_date: @selected_date,
        reserved_time: time
      ).count

      {
        time: "#{time} - #{(Time.parse(time) + 1.hour).strftime('%H:%M')}",
        value: time,
        available: 10 - booked_count,
        total: 10
      }
    end
  end


  def confirm
    @reservation_data = reservation_params.to_h
    @date = params[:date]
    @time = params[:time]

    @service_labels = {
    "kindergarten" => "犬の幼稚園",
    "nursery" => "保育園",
    "hotel" => "ホテル",
    "temporary_care" => "一時預かり"
  }
  end

  def complete
    if request.get?
      return
    end

    data = params[:reservation] || {}

    customer = Customer.find_or_create_by(
      owner_name: data[:owner_name],
      phone_number: data[:phone_number]
    )

    customer.update(
      address: data[:address],
      dog_name: data[:dog_name],
      dog_breed: data[:dog_breed],
      dog_age: data[:dog_age],
      dog_gender: data[:dog_gender]
    )

    Reservation.create!(
      customer: customer,

      reserved_date: params[:date],
      reserved_time: params[:time]&.split(" - ")&.first,

      owner_name: data[:owner_name],
      phone_number: data[:phone_number],
      dog_name: data[:dog_name],
      dog_age: data[:dog_age],
      dog_gender: data[:dog_gender],
      dog_breed: data[:dog_breed],

      service_type: data[:service_type],
      referral_source: data[:referral_source],
      address: data[:address],
      pickup_required: data[:pickup_required]
    )

    redirect_to reservations_complete_path
  end

  def new
    @reservation = Reservation.new
    year = params[:year]&.to_i || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    day = params[:day]&.to_i || Date.today.day

    @selected_date = Date.new(year, month, day)

    first_day = Date.new(year, month, 1)
    @start_wday = first_day.wday

    @days = (1..Date.new(year, month, -1).day).to_a

    @prev_month = @selected_date.prev_month
    @next_month = @selected_date.next_month

    # 空き時間
    slot_times = [ "09:00", "12:00", "15:00", "18:00" ]

    @time_slots = slot_times.map do |time|
      booked_count = Reservation.where(
        reserved_date: @selected_date,
        reserved_time: time
      ).count

      {
        time: "#{time} - #{(Time.parse(time) + 1.hour).strftime('%H:%M')}",
        value: time,
        available: 10 - booked_count,
        total: 10
      }
    end
  end

  def review
    @reservation = Reservation.new(reservation_params)
    @date = @reservation.reserved_date
    @time = @reservation.reserved_time
  end

  def create
    data = reservation_params

    customer = Customer.find_or_create_by(
      owner_name: data[:owner_name],
      phone_number: data[:phone_number]
    )

    @reservation = Reservation.new(data)
    @reservation.customer = customer

    if @reservation.save
      redirect_to admin_reservations_list_path(
        view: "calendar",
        date: @reservation.reserved_date
      )
    else
      Rails.logger.debug @reservation.errors.full_messages
    end
  end

  def list
    @view = params[:view] || "list"

    @reservations = Reservation.includes(:customer).order(reserved_date: :asc, reserved_time: :asc)
    @reserved_dates = Reservation.pluck(:reserved_date).map(&:to_date).uniq

    selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today

    @daily_reservations = @reservations.where(reserved_date: selected_date).order(reserved_time: :asc)
    @daily_reservations_grouped = @daily_reservations.group_by(&:service_type)
    @reservation_counts = Reservation.group(:reserved_date).count.transform_keys(&:to_date)
  end

  def destroy_reservation
    reservation = Reservation.find(params[:id])
    reservation.destroy

    redirect_to admin_reservations_list_path, notice: "予約を削除しました"
  end



  def edit_reservation
    @reservation = Reservation.find(params[:id])
  end

  def update_reservation
    @reservation = Reservation.find(params[:id])

    if @reservation.update(reservation_params)
      @reservation.customer.update(
        owner_name: @reservation.owner_name,
        phone_number: @reservation.phone_number,
        dog_name: @reservation.dog_name,
        dog_breed: @reservation.dog_breed
      )

      redirect_to admin_reservations_list_path, notice: "予約を更新しました"
    else
      render :edit_reservation
    end
  end

  private


  def reservation_params
    params.fetch(:reservation, {}).permit(
      :owner_name,
      :phone_number,
      :dog_name,
      :dog_age,
      :dog_gender,
      :dog_breed,
      :service_type,
      :referral_source,
      :address,
      :pickup_required,
      :reserved_date,
      :reserved_time
    )
  end

  def customer_params
    params.require(:customer).permit(
      :owner_name,
      :phone_number,
      :address,
      :dog_name,
      :dog_breed,
      :dog_age,
      :dog_gender
    )
  end
end
