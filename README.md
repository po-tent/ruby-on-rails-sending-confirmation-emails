# Odin Flight Booker

Created as part of the Odin Project [curriculum](https://www.theodinproject.com/courses/ruby-on-rails/lessons/building-advanced-forms). View [live page](https://odin-air.herokuapp.com/).

### Functionality

Search and book flights for Odin Air's flight offerings of November, 2021. The drop down menus for Origin, Destination, and Date are generated based on data from the relevant database tables. If no option is selected, the search is performed without that parameter (i.e. all fields left blank would return all flights, though I limited the results to 1,000).

There is a many to many relationship between bookings and passengers. Bookings can be searched by confirmation number or by email.

I wrote basic RSpec tests for the models and for the `Bookings Controller`.

###### Mailers

[Part 2](https://www.theodinproject.com/courses/ruby-on-rails/lessons/sending-confirmation-emails) of this project was to send a confirmation email to all passengers after a new booking is made. In the development environment, the `letter_opener` gem is used to view the delivered email. In production, Yahoo Mail delivers mail over SMTP protocol.

### Thoughts

###### Forms

I wanted a search's parameters to still be reflected in the select menus when the results were displayed. It is fairly straightforward to do this in HTML, but I found it difficult using Rails helpers since that functionality seems designed around building models as part of a POST#create flow. I have a feeling the best way to do this would be to make a `Search` model and have the search form build an instance of it. That way validations could be customized for the search and Rails would perform its normal behind the scenes work. I toyed with the idea, but decided to just have the form build a `Flight` object. I only needed to add `attr_accessor :tickets` to the model and include both `search_params` and `flight_params` in the `Flights Controller` (one for sending the search form and one for actually creating a `Flight` object). I originally had `attr_accessor :passengers`, which caused a lot of confusion when I later added a `passengers` association to the model.

Dealing with nested forms was made especially challenging because of the many to many relationship between `bookings` and `passengers` and the uniqueness constraint on the `email` column. Rails figures out how to create the `PassengerBooking` join table entries on its own, which is nice. If a booking is made with an existing `passenger` (matching both `name` and `email`), that existing passenger is assigned to the booking. If a booking is made with an existing `email` but a `name` that does not match, the booking form will be rendered again with the uniqueness error shown.

There ended up being a fairly easy solution to achieve this presented in [this](https://medium.com/inview-technical-blog/rails-5-using-find-or-create-by-for-nested-attributes-ff633aee62a1) article: a `before_save` callback:

```ruby
def find_or_create_passenger
	self.passengers = self.passengers.map do |passenger|
		Passenger.find_or_create_by(email: passenger.email, name: passenger.name)
	end
end
```

I had to switch to a `before_validation` callback so that the uniqueness validation on `email` wouldn't trigger first.

This worked well in most cases but I was running into a puzzling error in cases where an existing passenger is entered into the booking form, the above callback runs, and a validation error on another passenger triggers the booking form to be rendered again. At this point, `params[:booking]` would look something like this:

```ruby
"booking"=>{"flight_id"=>"24", "passengers_attributes"=>{"0"=>{"name"=>"ken", "email"=>"ken@gmail.com", "id"=>11}, "1"=>{"name"=>"Beth", "email"=>"beth@gmail.com"}}}
```

The first passenger now has `"id" => 11` in its attribute hash, a result of `find_or_create_passenger`. Even though that passenger exists and its `id` is 11, this will cause the following error when calling `Booking.new`:

```pseudocode
ActiveRecord::RecordNotFound at /bookings
Couldn't find Passenger with ID=11 for Booking with ID=
```

I think this is related to some limitations of `accepted_nested_attributes_for` as discussed [here](https://github.com/rails/rails/issues/7256). I worked for quite a while trying to figure something out, and eventually found that a solution was to add `<%= passengers_form.hidden_field :id, value: nil %>` to the new booking form, which will result in `params[:booking]` looking like this after the sequence described above:

```
"booking"=>{"flight_id"=>"24", "passengers_attributes"=>{"0"=>{"name"=>"ken", "email"=>"ken@gmail.com", "id"=>nil}, "1"=>{"name"=>"Beth", "email"=>"beth@gmail.com"}}}
```

This will not throw the `ActiveRecord::RecordNotFound` error.

I also clarified the `inverse_of` relationship in the `Booking` and `Passenger` models because I've read sometimes that can fix issues with many to many relationships, but I don't think that made a difference here.

###### Database Columns

I originally had one `datetime` column for `takeoff` in the `Flights` table. In order to search by date I had to separate `takeoff` from the other parameters so that I could cast it as a `date` (a PostgreSQL function):

```ruby
Flight.where(flight_params).where('takeoff::date = ?', params[:date])
```

This probably would have been simpler if I weren't building off a model. But regardless, I eventually realized that this and other issues would become much simpler if I just separated the date and time into two columns.

###### Many to Many Relationship

I have not used `has_and_belongs_to_many` before in a project and thought that the relationship between `bookings` and `passengers` was a good candidate, but I was persuaded not to by a [number](https://cobwwweb.com/why-i-dont-use-has-and-belongs-to-many-in-rails) of [articles](https://flatironschool.com/blog/why-you-dont-need-has-and-belongs-to-many) that discouraged their use altogether. I also was concerned whether I would be able add a `through` association onto a `has_and_belongs_to_many` association, and it appeared that this was not possible. With `has_many :through`, however, I can:

```ruby
has_many :passenger_bookings
has_many :bookings through: :passenger_bookings
has_many :flights, through: :bookings
```

When creating the `passenger_bookings` join table I made a point to use `id: false` in the migration. I didn't like the idea of having an `id` on a join table. However, this caused problems when calling `destroy` on a `Passenger` or `Booking` object (which had `dependent: :destroy` on the association). Apparently Rails cannot run `destroy` on records without an `id`, as discussed [here](https://github.com/rails/rails/issues/25347) and [here](https://stackoverflow.com/questions/23165282/error-zero-length-delimited-identifier-at-or-near-line-1-delete-from-reg/30542991). The stackoverflow link has the suggestion of switching to `dependent: :delete_all`, which worked well for me. The best solution, however, might be to just allow join tables to have an otherwise useless `id` column (also discussed on stackoverflow).

###### Flight and Confirmation Numbers

I wanted a flight's flight number to not be its `id` but its chronological ranking for that day's flights. I decided to add a database column for `flight_number` rather than calculate it anew each time it was needed. This means that if a new flight is created later flights that day will have incorrect `flight_numbers`. Since this functionality is not on the user end, I was ok with that. After seeding the database, I can run `Flight.reset_all_flight_numbers!` to ensure all `flight_numbers` are correct.

A `booking's` `confirmation` is created by a `before_save` callback and is used as the `id` in a `booking_path`. By [overriding](https://guides.rubyonrails.org/routing.html#overriding-named-route-parameters) `ActiveRecord::Base#to_param` to use `confirmation` instead of `id`, I was able to still use URL helpers like this: `booking_path(booking)`.

###### Mail

I ran into a number of difficulties with mail. Calling `PassengerMailer` directly from the Rails Console resulted in a `NameError (uninitialized constant PassengerMailer)` until I called `reload!`. This is discussed [here](https://github.com/rails/rails/issues/38174), and seems to be an issue with Spring that can be fixed with `spring stop`. Once the console recognized `PassengerMailer`, though, I was also getting an error complaining about not having `default_url_options` defined, even though it was. Closing the Terminal window and starting fresh solved both problems — I think this accomplishes the same thing that `spring stop` would have.

Trying to get SendGrid to work was a disaster. First my app was banned I guess because I was trying to change my username from the one they generated into something I would recognize. I looked into choosing another Heroku addon instead, but all the others were either very limited in the free tier or did not have documentation for a Rails setup. I eventually decided to delete my entire app on Heroku and make a new one so that I could try SendGrid again. When I saw that `heroku addons:create sendgrid:starter` successfully created a `SENDGRID_USERNAME` and `SENDGRID_PASSWORD` I took a break and then got banned again (I think because I didn't confirm my account with an email address quickly enough). I deleted this app as well to try one more time, and this time got a little further but couldn't finish setting up my account with 2-factor authentication, which they require, because they said my phone number was invalid (which it isn't). Certain buttons during their sign in process (like to skip 2-factor auth) just didn't do anything, the error messages were nondescriptive, and their support seems to be almost inaccessible. Google searches yielded many accounts of similar issues. In short, I don't expect to be using SendGrid in the future. I ultimately was able to send mail using no Heroku addons, just the included Rails `mail` gem.

I decided to make a Yahoo Mail account `odinair@yahoo.com` to send from — for fun, but also because I didn't really want my Gmail accounts involved. I had a tough time finding the right SMTP settings to get it to work, but eventually did (view in `config/production.rb`). Another important key was to make an app password, explained [here](https://help.yahoo.com/kb/SLN15241.html?). I knew to look for that because the Rails Guide mentions it for Gmail, but I was thrown off by Yahoo's description of it being for "1 time use."

Adding `protocol: 'https'` to the production `default_url_options` makes URL links go to the secure version of the app. (I hadn't realized before that Heroku apps are on both `http` and `https`.)

-Andrew Hayhurst