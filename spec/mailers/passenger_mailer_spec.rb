require "rails_helper"

RSpec.describe PassengerMailer, type: :mailer do
  let(:p1) { FactoryBot.build(:passenger) }
  let(:p2) { FactoryBot.create(:passenger) }
  let(:booking) do
    booking = FactoryBot.create(:booking)
    booking.passengers = [p1, p2];
    booking
  end
  let(:mail) { PassengerMailer.with(booking_id: booking.id).thank_you }

  it 'renders the headers' do
    expect(mail.subject).to eq("Thank you for booking Flight #{booking.flight.formatted_flight_number}!")
    expect(mail.to).to match_array(booking.passengers.pluck(:email))
    expect(mail.from).to eq(['odinair@yahoo.com'])
    expect(mail.content_type).to start_with('multipart/alternative') #html / text support
  end

  it "renders the body" do
    line1 = "Thank you for booking Flight OA#{booking.flight.flight_number} with Odin Air! Please review your trip details below."
    line2 = "Confirmation Number: #{booking.confirmation}"
    link = booking_url(booking)
    expect(mail.body.encoded).to match(line1)
    expect(mail.body.encoded).to match(line2)
    expect(mail.body.encoded).to match(link)
  end

  # All 'sent' emails are gathered into the ActionMailer::Base.deliveries array.
  it 'welcome_email is sent' do
      expect {
          mail.deliver_now
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'welcome_email is sent to the right user' do
      mail.deliver_now
      expect(ActionMailer::Base.deliveries.last.to).to match_array(booking.passengers.pluck(:email))
  end
end
