class ReservationsController < ApplicationController
  def admin
  @reservations = Reservation.order(created_at: :desc)

  @stats = {
    total_customers: 248,
    monthly_bookings: 87,
    completed_bookings: 156,
    monthly_sales: "¥892,000"
  }
  end
  def index
    year = params[:year]&.to_i || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    day = params[:day]&.to_i || Date.today.day

    @selected_date = Date.new(year, month, day)

    first_day = Date.new(year, month, 1)
    @start_wday = first_day.wday

    @days = (1..Date.new(year, month, -1).day).to_a

    @prev_month = @selected_date.prev_month
    @next_month = @selected_date.next_month

    @selected_time = params[:time]

    @time_slots = [
      { time: "09:00 - 10:00", available: 2, total: 6 },
      { time: "10:00 - 11:00", available: 3, total: 6 },
      { time: "11:00 - 12:00", available: 3, total: 6 },
      { time: "13:00 - 14:00", available: 3, total: 6 },
      { time: "14:00 - 15:00", available: 3, total: 6 },
      { time: "15:00 - 16:00", available: 3, total: 6 }
    ]
  end


  def confirm
    @selected_date = params[:date]
    @selected_time = params[:time]
  end

  def complete
    Reservation.create(
    reserved_date: params[:date],
    reserved_time: params[:time]
  )
  end
end
