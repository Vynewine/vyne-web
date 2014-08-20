class NotesWines < ActiveRecord::Base
  belongs_to :wine
  belongs_to :wine_note
end
