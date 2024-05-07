class WorkEventSerializer
  include JSONAPI::Serializer
  attributes :status, :date, :description, :work_id
end
