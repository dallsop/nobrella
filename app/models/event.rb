class Event < ActiveRecord::Base
  validates :start, presence: true, uniqueness: {scope: [:day, :user_id]}
  validates :day, presence: true

  belongs_to :user
  belongs_to :location
end
