class Event < ActiveRecord::Base
  validates :Start, presence: true, uniqueness: {scope: [:Day, :user_id]}
  validates :Day, presence: true

  belongs_to :user
  belongs_to :location
end
