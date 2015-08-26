class Location < ActiveRecord::Base
  validates :Name, presence:true, uniqueness: {scope: :user_id}

  belongs_to :user
  belongs_to :event
end
