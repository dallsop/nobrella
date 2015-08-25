class Location < ActiveRecord::Base
  validates :name, presence:true, uniqueness: {scope: :user}

  belongs_to :user
end
