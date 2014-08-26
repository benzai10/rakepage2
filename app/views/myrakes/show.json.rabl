object @rake
attributes :id, :name

child :heap do
  attributes :id

  child :leaflets do
    attributes :id, :title, :content, :published_at
  end
end

child :feed_leaflets do
  attributes :id, :title, :content, :published_at
end

#extends "myrakes/show"