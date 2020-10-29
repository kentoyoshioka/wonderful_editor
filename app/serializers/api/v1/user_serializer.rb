class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :article
end
