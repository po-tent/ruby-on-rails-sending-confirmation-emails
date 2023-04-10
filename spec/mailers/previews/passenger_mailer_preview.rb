# Preview all emails at http://localhost:3000/rails/mailers/passenger_mailer
class PassengerMailerPreview < ActionMailer::Preview
  def thank_you
    PassengerMailer.with(booking_id: Booking.first.id).thank_you
  end
end
