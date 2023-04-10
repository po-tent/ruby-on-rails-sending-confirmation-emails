require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  let(:flight) { FactoryBot.create(:flight) }
  let(:p1) { FactoryBot.build(:passenger) }
  let(:p2) { FactoryBot.create(:passenger) }
  let(:booking) { FactoryBot.create(:booking) }

  describe 'GET #new' do
    it 'requires a selected number of tickets' do
      get :new
      expect(response).to redirect_to(root_url)
      expect(flash[:alert]).to eq('You must select the number of passengers in your search in order to book a flight.')
    end

    it 'renders new template' do
      get :new, params: { tickets: 2,
                          flight_id: flight.id }
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'redirects to bookings show page on successful booking' do
      post :create, params: { booking: { flight_id: flight.id,
                                         passengers_attributes: { '0' => { name: p1.name, email: p1.email },
                                                                 '1' => { name: p2.name, email: p2.email }}}}
      expect(response).to redirect_to(booking_path(Booking.last.confirmation))
    end

    it 'validates presence of name' do
      post :create, params: { booking: { flight_id: flight.id,
                                         passengers_attributes: { '0' => { email: p1.email },
                                                                 '1' => { name: p2.name, email: p2.email }}}}
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq('The highlighted fields cannot be left blank. ')
    end

    it 'validates presence of email' do
      post :create, params: { booking: { flight_id: flight.id,
                                         passengers_attributes: { '0' => { name: p1.name },
                                                                 '1' => { name: p2.name, email: p2.email }}}}
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq('The highlighted fields cannot be left blank. ')
    end

    it 'validates uniqueness of email' do
      post :create, params: { booking: { flight_id: flight.id,
                                         passengers_attributes: { '0' => { name: p1.name, email: p1.email },
                                                                 '1' => { name: 'Incorrect Name', email: p2.email }}}}
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq('The highlighted email address has been taken by a user with a different name.')
    end
  end

  describe 'GET #show' do
    it 'renders show page' do
      get :show, params: { id: booking.confirmation }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #index' do
    it 'redirects to search page' do
      get :index
      expect(response).to redirect_to(search_bookings_path)
    end
  end

  describe 'GET #search' do
    it 'renders empty search page if not coming from search form' do
      get :search
      expect(response).to render_template(:search)
    end

    it 'requires confirmation number or email address to be selected to perform search' do
      get :search, params: { button: '' }
      expect(response).to redirect_to(search_bookings_url)
      expect(flash[:alert]).to eq('You must select to search by Confirmation Number or Email Address.')
    end

    it 'redirects to booking if existing confirmation given' do
      get :search, params: { button: '',
                             search_field: 'confirmation',
                             search_param: booking.confirmation }
      expect(response).to redirect_to(booking_path(booking.confirmation))
    end

    it 'redirects to booking if existing confirmation given' do
      get :search, params: { button: '',
                             search_field: 'confirmation',
                             search_param: '404' }
      expect(response).to redirect_to(search_bookings_url)
      expect(flash[:alert]).to eq('No booking could be found with the given parameters.')
    end

    it 'renders search page when searching by email' do
      booking.passengers << p1
      get :search, params: { button: '',
                             search_field: 'email',
                             search_param: p1.email }
      expect(response).to render_template(:search)
      expect(flash[:alert]).to be nil
    end

    it 'flash[:alert] notifies if no booking was found' do
      get :search, params: { button: '',
                             search_field: 'email',
                             search_param: 'no_booking_here@gmail.com' }
      expect(response).to render_template(:search)
      expect(flash[:alert]).to eq('No booking could be found with the given parameters.')
    end
  end
end