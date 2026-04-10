class ReservationsController < ApplicationController
  def customer_info
    @reservation = Reservation.new
  end

  def customers
    if params[:search].present?
      @customers = Customer.where(
        "owner_name LIKE ? OR phone_number LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      ).order(created_at: :desc)
    else
      @customers = Customer.order(created_at: :desc)
    end
  end

  def destroy_customer
    customer = Customer.find(params[:id])
    customer.destroy

    redirect_to "/admin/customers"
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

    slot_times = [
      "09:00 - 10:00",
      "10:00 - 11:00",
      "11:00 - 12:00",
      "13:00 - 14:00",
      "14:00 - 15:00",
      "15:00 - 16:00"
    ]

    @time_slots = slot_times.map do |slot_time|
      booked_count = Reservation.where(
        reserved_date: @selected_date,
        reserved_time: slot_time
      ).count

      total = 6
      available = total - booked_count

      {
        time: slot_time,
        available: available,
        total: total
      }
    end
  end


  def confirm
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
      reserved_date: params[:date],
      reserved_time: params[:time],
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
      :pickup_required
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
