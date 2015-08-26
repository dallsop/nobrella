class Event < ActiveRecord::Base
  validates :Start, presence:true, uniqueness: {through: :Day}
  validates :Day, presence:true

  belongs_to :user
  has_many :locations
end
