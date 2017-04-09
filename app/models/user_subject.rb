class UserSubject < ApplicationRecord
  belongs_to :user_id
  belongs_to :subject_id
end
