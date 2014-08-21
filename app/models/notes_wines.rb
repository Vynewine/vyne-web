class NotesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :note
end
