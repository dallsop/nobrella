class Location < ActiveRecord::Base
  validates :Name, presence: true, uniqueness: {scope: :user_id}
  validates :Address, presence: true
  belongs_to :user
  has_many :events
end
