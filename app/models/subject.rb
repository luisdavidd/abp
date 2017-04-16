class Subject < ApplicationRecord
  belongs_to :user_id
  has_many :subject_nrcs
end
