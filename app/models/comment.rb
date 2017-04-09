class Comment < ApplicationRecord
  belongs_to :offer
  belongs_to :user
end
