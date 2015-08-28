class Location < ActiveRecord::Base
  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates :address, presence: true
  belongs_to :user
  has_many :events
end
