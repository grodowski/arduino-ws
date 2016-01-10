# SensorRepository is responsible for interacting with the Mongoid data model.
# TODO: introduce support for show and share with device_socket_server
class SensorRepository
  def initialize(db, user_oid)
    @db = db
    @user_oid = user_oid
  end

  def all
    db.collection(:sensors)
      .find(user_id: user_oid, fields: [:_id, :device_uid])
  end

  private

  attr_reader :db, :user_oid
end
